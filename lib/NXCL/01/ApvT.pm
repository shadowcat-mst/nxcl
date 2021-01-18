package NXCL::01::ApvT;

use NXCL::01::Utils qw(rnilp);
use NXCL::01::ReprTypes qw(ValR);
use NXCL::01::TypeFunctions qw(cons_List);
use NXCL::01::TypeExporter;

export make => sub ($opv) { _make ValR ,=> $opv };

method combine => sub ($scope, $args, $apv, $kstack) {
  return (
    [ EVAL => $scope => $args ],
    cons_List([ CMB6 => $scope => raw($apv) ], $kstack),
  );
};

1;
