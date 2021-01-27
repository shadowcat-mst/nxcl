package NXCL::01::NameT;

use NXCL::01::Utils qw(type raw panic);
use NXCL::01::ReprTypes qw(CharsR);
use NXCL::01::TypeFunctions qw(
  OpDictT ValT VarT make_String
  cons_List make_List empty_List
);
use NXCL::01::TypeExporter;

export make => \&make;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $cmb, $self, $args) {
  my $store = raw $scope;
  my $store_type = type($store);
  if ($store_type == OpDictT()) {
    my $cell = raw($store)->{raw($self)};
    panic unless $cell;
    if (type($cell) == ValT or type($cell) == VarT) {
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
