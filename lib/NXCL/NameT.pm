package NXCL::NameT;

use NXCL::Utils qw(mset object_is raw panic);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(
  OpDict_Inst Val_Inst Var_Inst
  make_String make_List empty_List
);
use NXCL::TypePackage;

export make => \&make;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $cmb, $self, $args) {
  my $store = raw $scope;
  if (object_is $store, OpDict_Inst) {
    my $cell = raw($store)->{raw($self)};
    panic "No value for ${\raw($self)} in current scope" unless $cell;
    if (mset($cell) == Val_Inst or mset($cell) == Var_Inst) {
      return JUST raw($cell);
    }
    return CMB9 $cell => empty_List;
  }
  return (
    CMB9($store => make_List(make_String(raw($self)))),
    CMB6(empty_List),
  );
};

1;
