package NXCL::01::NameT;

use NXCL::01::TypeExporter;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $self, $, $kstack) {
  my $store = deref $scope;
  my $store_type = type($store);
  if ($store_type == OpDict_T()) {
    my $cell = raw($store)->{raw($self)};
    panic unless $cell;
    if (type($cell) == $Types{Val}) {
      return evaluate_to_value(undef, undef, deref($cell), $kstack);
    }
    return (
      [ CMB9 => $scope => nil() => $cell ],
      $kstack,
    );
  }
  return (
    [ CMB9 => $scope => make_List(String(raw($self))) => $store ],
    cons_List([ CMB9 => $scope => nil() ], $kstack),
  );
};

1;
