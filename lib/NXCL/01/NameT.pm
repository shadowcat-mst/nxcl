package NXCL::01::NameT;

use NXCL::01::TypeExporter;

sub make ($name) { _make CharsR ,=> $name }

raw method evaluate => sub ($scope, $self, $, $kstack) {
  my $store = deref $scope;
  my $store_type = type($store);
  if ($store_type == OpDict_T()) {
    my $cell = raw($store)->{raw($self)};
    panic unless $cell;
    if (type($cell) == $Types{Val}) {
      return evaluate_to_value($scope, deref($cell), $kstack);
    }
    return (
      [ CMB9 => $scope => nil() => $cell ],
      $kstack,
    );
  }
  return (
    [ CMB9 => $scope => list1(String(raw($self))) => $store ],
    cons([ CMB9 => $scope => nil() ], $kstack),
  );
};

1;
