package NXCL::NameT;

use NXCL::Utils qw(mset object_is raw panic uncons);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(
  make_String make_List cons_List empty_List
);
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

methodn to_xcl_string {
  return JUST make_String raw $self;
}

1;
