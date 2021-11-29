package NXCL::FunT;

use NXCL::Utils qw(flatten raw);
use NXCL::TypeFunctions qw(
  make_List empty_List Val
  make_String make_Name make_Bool
);
use NXCL::ReprTypes qw(DictR);
use NXCL::MethodUtils qw($DOT_F);
use NXCL::TypePackage;

sub make ($scope, $argspec, $body, $is_opv = make_Bool(0)) {
  _make DictR ,=> {
    scope => $scope,
    argspec => $argspec,
    body => $body,
    is_opv => $is_opv,
  };
}

export make => \&make;

static new => sub ($self, $args) {
  return (
    GCTX(),
    LIST(),
    CALL('scope'),
    SNOC($args),
    CONS($self),
    CALL('_new')
  );
};

static _new => sub ($self, $args) {
  my ($scope, $argspec, $body, $is_opv) = flatten $args;
  return JUST make $scope, $argspec, $body, $is_opv;
};

method combine => sub ($self, $args) {
  my %me = %{raw($self)};
  return DOCTX $self, 0, undef, [

    # Setup args and grab context

    do {
      if (raw($me{is_opv})) {
        # Fexpr - unshift context onto args
        (
          GCTX(),
          DUP2(2, 'JUST'),
          SNOC($args),
          OVER(12, 'JUST'),
        );
      } else {
        # Lambda - evaluate args in calling environment
        (
          EVAL($args),
          OVER(12, 'JUST'),
          GCTX(),
        );
      }
    },

    # Create execution scope and setup return target

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
