package NXCL::01::ValT;

use NXCL::01::TypeExporter;

sub make ($val) { _make ValR ,=> $val }

method combine => sub ($scope, $args, $self, $kstack) {
  panic unless rnilp $args;
  return evaluate_to_value($scope, deref($self), $NIL, $kstack);
}

1;
