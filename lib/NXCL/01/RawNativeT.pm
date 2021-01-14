package NXCL::01::RawNativeT;

use NXCL::01::TypeExporter;

sub make ($sub) { _make NativeR ,=> $sub }

method combine => sub ($scope, $args, $value, $kstack) {
  deref($value)->($scope, $args, $value, $kstack);
}

q;
