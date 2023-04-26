package NXCL::FunT;

use NXCL::Utils qw(flatten raw);
use NXCL::TypeFunctions qw(
  make_List empty_List Val
  make_String make_Name make_Bool
);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypeSyntax;

export make ($scope, $argspec, $body, $is_opv = make_Bool(0)) {
  _make DictR ,=> {
    scope => $scope,
    argspec => $argspec,
    body => $body,
    is_opv => $is_opv,
  };
}

staticx new {
  return (
    GCTX(),
    LIST(),
    CALL('scope'),
    SNOC($args),
    CONS($self),
    CALL('_new')
  );
}

staticx _new {
  my ($scope, $argspec, $body, $is_opv) = flatten $args;
  return JUST make $scope, $argspec, $body, $is_opv;
}

methodx COMBINE {
  my %me = %{raw($self)};
  my $is_opv = 0+!!raw($me{is_opv});
  return (
    ($is_opv ? GCTX() : ()),
    DOCTX $self, undef, [

      # Setup args

      ($is_opv ? SNOC($args) : EVAL($args)),
      SETL('args'),

      # Setup return and defer dynamics

      DYNREG('return'),
      DYNREG('defer'),

      # Create execution scope

      CALL('derive', make_List($me{scope})),
      DUPL('scope'),

      # Unpack arguments

      SNOC(make_List(Val)),
      CALL('introscope'),
      DOCTX(undef, [
        USEL('args','JUST'),
        LIST($me{argspec}),
        CALL('ASSIGN_VALUE'),
      ]),
      DROP(),

      # Execute function body

      USEL('scope','JUST'),
      DOCTX(undef, [
        CMB9($me{body}, empty_List),
      ]),
    ]
  );
}

1;
