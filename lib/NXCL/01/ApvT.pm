package NXCL::01::ApvT;

use NXCL::01::Utils qw(raw);
use NXCL::01::ReprTypes qw(ValR);
use NXCL::01::TypeExporter;

export make => sub ($opv) { _make ValR ,=> $opv };

method combine => sub ($scope, $cmb, $self, $args) {
  return (
    [ EVAL => $scope => $args ],
    [ CMB6 => $scope => raw($self) ],
  );
};

1;
