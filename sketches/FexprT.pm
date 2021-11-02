package NXCL::FexprT;

use NXCL::Utils qw(panic);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypeFunctions qw(make_Val make_Scope make_OpDict make_List);
use NXCL::TypePackage;

export make => \&make;

sub make ($scope, $argspec, $body) {
  _make DictR ,=> {
    scope => $scope,
    argspec => $argspec,
    body => $body,
  };
}

wrap static new => sub ($scope, $cmb, $self, $args) {
  my ($argspec, $body) = flatten $args;
  return JUST make $argspec, $body;
};

method combine => sub ($callscope, $cmb, $self, $callargs) {
  my ($captured_scope, $argspec, $body)
    = @{raw($self)}{qw(scope argspec body)};
  # Limited temporary hack
  my $store = raw($captured_scope)->{store};
  panic 'NYI' unless object_is $store, OpDict_Inst;
  my $argval = make_Val($callargs);
  my %instore = (
    %{raw($store)},
    callscope => make_Val($callscope),
    callargs => $argval,
    thisargs => $argval,
    thisfunc => make_Val($self),
  );
  my $inscope = make_Scope(make_OpDict(\%instore), make_List(Val));
  return (
    RPLS($inscope),
    CALL(assign_value => make_List($argspec, $callargs)),
    DROP(),
    EVAL($body),
    OVER(),
    RPLS($callscope),
  );
};

1;
