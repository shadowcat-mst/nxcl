package NXCL::01::NameT;

use NXCL::01::Utils qw(mset raw panic);
use NXCL::01::ReprTypes qw(CharsR);
use NXCL::01::TypeFunctions qw(
  OpDict_Inst Val_Inst Var_Inst
  make_String make_List empty_List
);
use NXCL::01::TypePackage;

export make => \&make;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $cmb, $self, $args) {
  my $store = raw $scope;
  my $store_mset = mset($store);
  if ($store_mset == OpDict_Inst) {
    my $cell = raw($store)->{raw($self)};
    panic unless $cell;
    if (mset($cell) == Val_Inst or mset($cell) == Var_Inst) {
      return (
        [ JUST => raw($cell) ],
      );
    }
    return (
      [ CMB9 => $scope => $cell => empty_List ],
    );
  }
  return (
    [ CMB9 => $scope => $store => make_List(make_String(raw($self))) ],
    [ CMB6 => $scope => empty_List ],
  );
};

1;
