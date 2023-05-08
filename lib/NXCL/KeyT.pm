package NXCL::KeyT;

use NXCL::Utils qw(uncons raw);
use NXCL::TypeFunctions qw(
  make_KVPair list_Compound make_Name make_String make_List
  just_Native
);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export make ($val) { _make ValR ,=> $val }

static new {
  my ($key) = uncons($args);
  return JUST _make ValR ,=> $key;
}

method COMBINE {
  my ($value) = uncons($args);
  return JUST make_KVPair(raw($self), $value);
}

methodx AS_PLAIN_EXPR {
  # should have name-or-string logic here
  return (
    CALL(AS_PLAIN_EXPR => make_List(raw($self))),
    LIST(make_Name ':'),
    CMB9(just_Native \&list_Compound),
  );
}

1;
