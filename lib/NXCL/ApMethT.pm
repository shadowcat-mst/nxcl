package NXCL::ApMethT;

use NXCL::Utils qw(uncons raw);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(cons_List);
use NXCL::TypePackage;

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
