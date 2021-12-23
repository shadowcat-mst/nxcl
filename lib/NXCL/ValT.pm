package NXCL::ValT;

use NXCL::Utils qw(rnilp raw panic uncons);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export make ($val) { _make ValR ,=> $val }

staticx new {
  return JUST make((uncons $args)[0]);
}

methodn COMBINE {
  return JUST raw($self);
}

1;
