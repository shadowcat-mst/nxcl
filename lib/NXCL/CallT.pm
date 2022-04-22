package NXCL::CallT;

use NXCL::Utils qw(panic raw uncons rnilp);
use NXCL::TypeFunctions qw(make_List);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export of_list ($list) { _make ValR ,=> $list }

export make (@parts) { of_list(make_List @parts) }

methodn AS_PLAIN_EXPR { return JUST $self }

methodx EVALUATE {
  my $call_list = raw($self);
  panic "Empty call list" if rnilp($call_list);
  my ($first, $rest) = uncons($call_list);
  return (
    EVAL($first),
    (rnilp($rest)
      ? ()
      : (DROP(), EVAL(of_list($rest)))
    )
  );
}

1;
