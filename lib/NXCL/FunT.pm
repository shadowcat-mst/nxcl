package NXCL::FunT;

use NXCL::Utils qw(flatten raw);
use NXCL::TypeFunctions qw(
  make_List empty_List Val
  make_String
);
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

static new => sub ($scope, $self, $args) {
  my ($argspec, $body) = flatten $args;
  return JUST make $scope, $argspec, $body;
};

method combine => sub ($scope, $self, $args) {
  my %me = %{raw($self)};
  return DOCTX $self, 0, $scope, [
    # Evaluate args in calling environment

    EVAL($args),
    OVER(9, 'JUST'),

    # Create execution scope

    CALL(derive => make_List($me{scope})),
    OVER(2, 'CONS'),
    GCTX(),
    LIST(make_String('callctx')),
    CALL('with_dynamic_value'),
    DUP2(8, 'JUST'),

    # Unpack arguments

    SNOC(make_List(Val)),
    CALL('introscope'),
    DOCTX($self, 1, [
      LIST($me{argspec}),
      CALL('assign_value'),
    ]),
    DROP(),

    # Execute function body

    DOCTX($self, 0, [
      CMB9($me{body}, empty_List),
    ]),
  ];
};
