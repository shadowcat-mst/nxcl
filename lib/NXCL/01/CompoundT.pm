package NXCL::01::CompoundT;

use NXCL::01::Utils qw(flatten mset);
use NXCL::01::TypeFunctions qw(List_Inst make_List);
use NXCL::01::ReprTypes qw(ConsR);
use NXCL::01::TypePackage;

export make => sub ($call, $first, $second, @rest) {
  _make ConsR ,=> $first, make_List($second, @rest);
};

method evaluate => sub ($scope, $cmb, $self, $args) {
  my ($first, $second, @rest) = flatten $self;
  return (
    [ CMB9 => $first, $second ],
    map [ CMB6 => (mset($_) == List_Inst ? $_ : make_List($_)) ], @rest
  );
};

1;
