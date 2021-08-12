package NXCL::BaseScope;

use NXCL::Package;
use NXCL::Utils qw(uncons);
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
    String
    Val
  )),
  qw(make_Val make_Scope make_Scopener make_Native make_OpDict),
);
use NXCL::BaseOps qw(%OP_MAP);

my %opmeth = map {
  my ($opname, $opmeth) = ($_, $OP_MAP{$_});
  ($opname => make_Native set_subname "dot_${opmeth}" =>
    sub ($, $, $argsp) {
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
    '.' => $DOT,
    escape => $ESCAPE,
    "\\" => $ESCAPE,
    let => make_Scopener(Val),
    # var => make_Scopener(Var),
    %opmeth,
    map +($_ => __PACKAGE__->can($_)->()),
      @BASE_TYPES
  );
  +{
    map +($_ => make_Val($scope{$_})), sort keys %scope
  };
};

our $Scope = make_Scope $Store;

sub scope ($class = undef) { $Scope }

1;
