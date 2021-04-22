package NXCL::01::CompoundT;

use NXCL::01::Utils qw(flatten mset);
use NXCL::01::TypeFunctions qw(List_Inst make_List);
use NXCL::01::ReprTypes qw(ConsR);
use NXCL::01::TypePackage;

export make => sub ($call, $first, @rest) {
  _make ConsR ,=> $first, make_List(@rest);
};

method evaluate => sub ($scope, $cmb, $self, $args) {
  my ($first, @rest) = flatten $self;
  return (
    [ EVAL => $scope, $first ],
    map [ CMB6 => $scope, (mset($_) == List_Inst ? $_ : make_List($_)) ], @rest
  );
};

1;
