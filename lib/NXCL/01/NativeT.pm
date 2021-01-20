package NXCL::01::NativeT;

use NXCL::01::Utils qw(uncons raw);
use NXCL::01::ReprTypes(NativeR);
use NXCL::01::TypeExporter;

export make => sub ($sub) { _make NativeR ,=> $sub };

method combine => sub ($scope, $args, $value, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, raw($value)->($scope, $args) ].
    $kdr
  );
}

1;
