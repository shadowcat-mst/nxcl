package NXCL::FunT;

use NXCL::Utils qw(flatten raw);
use NXCL::TypeFunctions qw(
  make_List empty_List Val
  make_String make_Name
);
use NXCL::ReprTypes qw(DictR);
use NXCL::MethodUtils qw($DOT_F);
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

static _new => sub ($scope, $self, $args) {
  my ($lexicals, $argspec, $body) = flatten $args;
  return JUST make $lexicals, $argspec, $body;
};

method combine => sub ($scope, $self, $args) {
  my %me = %{raw($self)};
  return DOCTX $self, 0, undef, [
    # Evaluate args in calling environment

    EVAL($args),
    OVER(12, 'JUST'),

    # Create execution scope and setup return target

    GCTX(),
    DUP2(3, 'CONS'),
    LIST(make_Name('return_to')),
    CMB9($DOT_F),
    LIST(make_String('return-target')),
    CALL('set_dynamic_value'),
    DROP(),
    CALL('derive', make_List($me{scope})),
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
