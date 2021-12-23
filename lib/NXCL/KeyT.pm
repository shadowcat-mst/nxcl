package NXCL::KeyT;

use NXCL::Utils qw(uncons raw);
use NXCL::TypeFunctions qw(make_Pair);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export make ($val) { _make ValR ,=> $val }

static new {
  my ($key) = uncons($args);
  return JUST _make ValR ,=> $key;
}

method COMBINE {
  my ($value) = uncons($args);
  return JUST make_Pair(raw($self), $value);
}

1;
