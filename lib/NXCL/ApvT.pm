package NXCL::ApvT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

export make => sub ($opv) { _make ValR ,=> $opv };

method combine => sub ($scope, $cmb, $self, $args) {
  return (
    [ EVAL => $scope => $args ],
    [ CMB9 => $scope => raw($self) ],
  );
};

1;
