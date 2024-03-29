package NXCL::BaseScope;

use NXCL::Package;
use NXCL::Utils qw(uncons flatten raw meta_dict);
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
    Dict
    KVPair
    Scope
    IntroScope
    String
    Val
    Var
    Fun
    LvalueFun
    CxRef
    CxTemplate
  )),
  qw(make_Val make_Scope make_Scopener make_Native make_Dict),
  qw(make_ApMeth make_Apv make_String make_List make_Bool),
  qw(cons_List make_LvalueFun make_Key),
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

our $Store = make_Dict do {
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
          CALL(ASSIGN_VALUE => $args),
          DROP(),
          JUST($rhs)
        );
      }
    )),
    true => make_Bool(1),
    false => make_Bool(0),
    do => make_ApMeth(make_Native(set_subname "do" =>
            sub ($args) { CALL(COMBINE => $args) })),
    fun => make_ApMeth(make_Native(set_subname "fun" =>
             sub ($args) { CALL(new => cons_List(Fun, $args)) })),
    fexpr => make_ApMeth(make_Native(set_subname "fexpr" => sub ($args) {
               CALL(new => make_List(Fun, flatten($args), make_Bool(1)))
             })),
    ':' => make_Native(sub ($args) {
      my ($key) = uncons $args;
      return JUST make_Key $key;
    }),
    '%' => make_Native(sub ($args) {
      return CALL(new => cons_List(Dict, $args));
    }),
    return => make_Apv(make_Native(set_subname "return" =>
      sub ($args) { # dynamic('return')(arg0)
        my ($ret) = uncons($args);
        return (
          GCTX(),
          SNOC(make_List(make_String('return'))),
          CALL('get_dynamic_value'),
          SNOC(make_List($ret)),
          CALL('COMBINE'),
        );
      }
    )),
    defer => make_Apv(make_Native(set_subname "defer" =>
      sub ($args) { # dynamic('return')(arg0)
        my ($ret) = uncons($args);
        return (
          GCTX(),
          SNOC(make_List(make_String('defer'))),
          CALL('get_dynamic_value'),
          SNOC(make_List($ret)),
          CALL('COMBINE'),
        );
      }
    )),
    '^' => make_LvalueFun(
      make_Native(set_subname "get_dynamic" => sub ($args) {
        my ($namep) = uncons($args);
        return (
          GCTX(),
          SNOC(make_List(make_String(raw($namep)))),
          CALL('get_dynamic_value'),
        );
      }),
      make_Native(set_subname "set_dynamic" => sub ($args) {
        my ($targetp, $value) = flatten($args);
        my ($namep) = uncons($targetp);
        return (
          GCTX(),
          SNOC(make_List(make_String(raw($namep)), $value)),
          CALL('set_dynamic_value'),
        );
      }),
    ),
    'meta-dict-of' => make_Apv(
      make_Native(set_subname "meta_dict_of" => sub ($args) {
        my ($of) = uncons $args;
        return JUST meta_dict($of) // make_Dict({});
      })
    ),
    apply => make_Apv(make_Native(set_subname apply => sub ($args) {
      my ($call, $call_args) = uncons $args;
      return (
        EVAL($call),
        CMB6($call_args),
      );
    })),
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
