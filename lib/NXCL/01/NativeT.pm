package NXCL::01::NativeT;

use NXCL::01::TypeExporter;

sub make ($sub) { _make NativeR ,=> $sub }

raw method combine => sub ($scope, $args, $value, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, deref($value)->($scope, $args) ].
    $kdr
  );
}

1;
