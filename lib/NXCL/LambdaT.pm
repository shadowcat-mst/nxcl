package NXCL::LambdaT;

use NXCL::Utils qw(flatten raw);
use NXCL::TypeFunctions qw(make_List empty_List Val);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypePackage;

sub make ($scope, $argspec, $body) {
  _make DictR ,=> {
    scope => $scope,
    argspec => $argspec,
    body => $body,
  };
}

export make => \&make;

static new => sub ($scope, $cmb, $self, $args) {
  my ($argspec, $body) = flatten $args;
  return JUST make $scope, $argspec, $body;
};

method combine => sub ($scope, $cmb, $self, $args) {
  my %me = %{raw($self)};
  return (
    EVAL($args),
    OVER(5),
    CALL(derive => make_List($me{scope})),
    DUP2(8),
    SNOC(make_List(Val)),
    CALL('introscope'),
    DOCTX($self, 1, [
      LIST($me{argspec}),
      CALL('assign_value'),
    ]),
    DROP(),
    DOCTX($self, 1, [
      CMB9($me{body}, empty_List),
    ]),
  );
};
