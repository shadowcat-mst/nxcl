package NXCL::01::ApvT;

use NXCL::00::Runtime qw(rnilp);
use NXCL::01::TypeExporter;

sub make ($opv) { _make ValR ,=> $opv }

method combine => sub ($scope, $args, $apv, $kstack) {
  return (
    [ EVAL => $scope => $args ],
    cons_List([ CMB6 => $scope => deref($apv) ], $kstack),
  );
}

1;
