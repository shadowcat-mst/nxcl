package NXCL::01::ApMethT;

use NXCL::01::Utils qw(uncons raw);
use NXCL::01::ReprTypes qw(ValR);
use NXCL::01::TypeFunctions qw(cons_List);
use NXCL::01::TypeExporter;

export make => sub ($opv) { _make ValR ,=> $opv };

method combine => sub ($scope, $apv, $argsp, $kstack) {
  my ($obj, $args) = uncons($argsp);
  return (
    [ EVAL => $scope => $args ],
    cons_List(
      [ CONS => $obj ],
      [ CMB9 => $scope => raw($apv) ],
      $kstack
    )
  );
};

1;
