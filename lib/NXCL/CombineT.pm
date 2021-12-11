package NXCL::CombineT;

use NXCL::Utils qw(uncons);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(make_List cons_List);
use NXCL::TypeSyntax;

export make ($call, @args) { _make ConsR ,=> $call, make_List @args }
export cons ($call, $args) { _make ConsR ,=> $call, $args }
export list ($list) { _make ConsR ,=> uncons($list) }

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
