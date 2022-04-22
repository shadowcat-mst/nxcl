package NXCL::CombineT;

use NXCL::Utils qw(uncons flatten);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(make_List cons_List make_String just_Native);
use NXCL::TypeSyntax;

export make ($call, @args) { _make ConsR ,=> $call, make_List @args }
export cons ($call, $args) { _make ConsR ,=> $call, $args }
export list ($list) { _make ConsR ,=> uncons($list) }

methodn AS_PLAIN_EXPR {
  return (
    CALL(AS_PLAIN_EXPR => make_List make_List flatten $self),
    CMB9(just_Native \&list),
  );
}

methodx EVALUATE {
  my ($call, $call_args) = uncons $self;
  return (
    EVAL($call),
    CMB6($call_args),
  );
}

methodx ASSIGN_VALUE {
  my ($call, $call_args) = uncons $self;
  return (
    EVAL($call),
    SNOC(cons_List($call_args, $args)),
    CALL('ASSIGN_VIA_CALL'),
  );
}

1;
