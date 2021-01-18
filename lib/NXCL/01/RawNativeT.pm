package NXCL::01::RawNativeT;

use NXCL::01::TypeExporter;
use NXCL::01::ReprTypes qw(NativeR);
use NXCL::01::Utils qw(raw);

sub make ($sub) { _make NativeR ,=> $sub }

method combine => sub ($scope, $args, $value, $kstack) {
  raw($value)->($scope, $args, $value, $kstack);
};

1;
