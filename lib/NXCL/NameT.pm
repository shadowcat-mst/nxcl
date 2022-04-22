package NXCL::NameT;

use NXCL::Utils qw(mset object_is raw panic uncons);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(empty_List);
use NXCL::TypeSyntax;

export make ($name) { _make CharsR ,=> $name }

methodn EVALUATE {
  return GETN($self);
}

methodx ASSIGN_VALUE {
  return JUST empty_List if raw($self) eq '$';
  my ($new_value) = uncons($args);
  return SETN($self, $new_value);
}

methodn AS_PLAIN_EXPR { return JUST $self }

1;
