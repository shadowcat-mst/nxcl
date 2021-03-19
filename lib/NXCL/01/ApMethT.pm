package NXCL::01::ApMethT;

use NXCL::01::Utils qw(uncons raw);
use NXCL::01::ReprTypes qw(ValR);
use NXCL::01::TypeFunctions qw(cons_List);
use NXCL::01::TypePackage;

export make => sub ($opv) { _make ValR ,=> $opv };

method combine => sub ($scope, $cmb, $self, $args) {
  my ($inv, $method_args) = uncons($args);
  return (
    [ EVAL => $scope => $method_args ],
    [ CONS => $inv ],
    [ CMB9 => $scope => raw($self) ],
  );
};

1;
