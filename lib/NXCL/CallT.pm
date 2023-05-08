package NXCL::CallT;

use NXCL::Utils qw(panic raw uncons rnilp);
use NXCL::TypeFunctions qw(make_List just_Native);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export list ($list) { _make ValR ,=> $list }

export make (@parts) { list(make_List @parts) }

methodx AS_PLAIN_EXPR {
  my $list = raw($self);
  return (
    CALL(AS_PLAIN_EXPR => make_List $list),
    CMB9(just_Native \&list),
  );
}

methodn EVALUATE {
  my $call_list = raw($self);
  panic "Empty call list" if rnilp($call_list);
  my ($first, $rest) = uncons($call_list);
  return (
    EVAL($first),
    (rnilp($rest)
      ? ()
      : (DROP(), EVAL(list($rest)))
    )
  );
}

1;
