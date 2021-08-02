package NXCL::CompoundT;

use NXCL::Utils qw(flatten mset);
use NXCL::TypeFunctions qw(List_Inst make_List);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypePackage;

export make => sub ($first, @rest) {
  _make ConsR ,=> $first, make_List(@rest);
};

method evaluate => sub ($scope, $cmb, $self, $args) {
  my ($first, @rest) = flatten $self;
  return (
    EVAL($first),
    map CMB6(mset($_) == List_Inst ? $_ : make_List($_)), @rest
  );
};

1;
