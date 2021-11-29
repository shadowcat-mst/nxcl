package NXCL::BaseScope;

use NXCL::Package;
use NXCL::Utils qw(uncons flatten);
use NXCL::MethodUtils;
use NXCL::ExprUtils;
use NXCL::OpUtils;
use Sub::Util qw(set_subname);
use vars qw(@BASE_TYPES);
use NXCL::TypeFunctions (
  (@BASE_TYPES = qw(
    ApMeth
    Apv
    Bool
    Call
    Combine
    Compound
    Curry
    Dict
    Key
    Int
    List
    Name
    Native
    Numeric
    OpDict
    Pair
    Scope
    IntroScope
    String
    Val
    Var
    Fun
  )),
  qw(make_Val make_Scope make_Scopener make_Native make_OpDict),
  qw(make_ApMeth make_Apv make_String make_List make_Bool),
  qw(cons_List),
);
use NXCL::BaseOps qw(%OP_MAP);

my %opmeth = map {
  my ($opname, $opmeth) = ($_, $OP_MAP{$_});
  ($opname => make_Native set_subname "dot_${opmeth}" =>
    sub ($argsp) {
      my ($obj, $args) = uncons $argsp;
      return (
        EVAL($obj),
        SNOC($args),
        CALL($opmeth),
      );
    })
} (
  sort keys %OP_MAP
);

our $Store = make_OpDict do {
  my %scope = (
    dot => $DOT,
    dot_f => $DOT_F,
    '.' => $DOT,
    escape => $ESCAPE,
    "\\" => $ESCAPE,
    let => make_Scopener(Val),
    var => make_Scopener(Var),
    # needs an InCurScope to go with Scopener or similar
    # cur => ...
    # Using ApMethT to get the RHS eval-ed and the LHS not is kinda cheating.
    '=' => make_ApMeth(make_Native(set_subname "assign_guts" =>
      sub ($args) {
        my ($lhs, $cdr) = uncons($args);
        my ($rhs) = uncons($cdr);
        return (
          CALL(assign_value => $args),
          DROP(),
          JUST($rhs)
        );
      }
    )),
    true => make_Bool(1),
    false => make_Bool(0),
    do => make_ApMeth(make_Native(set_subname "do" =>
            sub ($args) { CALL(combine => $args) })),
    fun => make_ApMeth(make_Native(set_subname "fun" =>
             sub ($args) { CALL(new => cons_List(Fun, $args)) })),
    fexpr => make_ApMeth(make_Native(set_subname "fexpr" => sub ($args) {
               CALL(new => make_List(Fun, flatten($args), make_Bool(1)))
             })),
    return => make_Apv(make_Native(set_subname "return" =>
      sub ($args) { # dynamic('return-target')(arg0)
        my ($ret) = uncons($args);
        return (
          GCTX(),
          SNOC(make_List(make_String('return-target'))),
          CALL('get_dynamic_value'),
          SNOC(make_List($ret)),
          CALL('combine'),
        );
      }
    )),
    %opmeth,
    map +($_ => __PACKAGE__->can($_)->()),
      @BASE_TYPES
  );
  +{
    map +($_ => make_Val($scope{$_})), sort keys %scope
  };
};

sub scope ($class = undef) { make_Scope $Store }

1;
