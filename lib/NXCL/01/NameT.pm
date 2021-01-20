package NXCL::01::NameT;

use NXCL::01::Utils qw(type raw $NIL);
use NXCL::01::ReprTypes qw(CharsR);
use NXCL::01::TypeFunctions qw(
  OpDictT ValT VarT make_String cons_List make_List
);
use NXCL::01::TypeExporter;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $self, $, $kstack) {
  my $store = raw $scope;
  my $store_type = type($store);
  if ($store_type == OpDictT()) {
    my $cell = raw($store)->{raw($self)};
    panic unless $cell;
    if (type($cell) == ValT or type($cell) == VarT) {
      return ([ JUST => $scope => raw($cell) ], $kstack);
    }
    return (
      [ CMB9 => $scope => $NIL => $cell ],
      $kstack,
    );
  }
  return (
    [ CMB9 => $scope => make_List(make_String(raw($self))) => $store ],
    cons_List([ CMB9 => $scope => $NIL ], $kstack),
  );
};

1;
