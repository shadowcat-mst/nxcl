package NXCL::NameT;

use NXCL::Utils qw(mset object_is raw panic uncons);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(
  make_String make_List cons_List empty_List
);
use NXCL::TypePackage;

export make => \&make;

sub make ($name) { _make CharsR ,=> $name }

method EVALUATE => sub ($self, $args) {
  return GETN($self);
};

method assign_value => sub ($self, $args) {
  return JUST empty_List if raw($self) eq '$';
  my ($new_value) = uncons($args);
  return SETN($self, $new_value);
};

method to_xcl_string => sub ($self, $args) {
  return JUST make_String raw $self;
};

1;
