package NXCL::01::RawNativeT;

use NXCL::01::Utils qw(raw);
use NXCL::01::ReprTypes qw(NativeR);
use NXCL::01::TypeExporter;

sub make ($sub) { _make NativeR ,=> $sub }

method combine => sub ($scope, $value, $args, $kstack) {
  raw($value)->($scope, $value, $args, $kstack);
};

1;
