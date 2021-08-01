package NXCL::ApMethT;

use NXCL::Utils qw(uncons raw);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(cons_List make_List empty_List make_String);
use NXCL::TypePackage;

export make => sub ($opv) { _make ValR ,=> $opv };

method to_xcl_string => sub ($scope, $, $self, $) {
  state $fmt = make_String('ApMeth(%s)');
  return (
    CALL($scope => 'to_xcl_string' => make_List(raw($self))),
    SNOC(empty_List),
    CONS($fmt),
    CALL($scope => 'sprintf'),
  );
};

method combine => sub ($scope, $cmb, $self, $args) {
  my ($inv, $method_args) = uncons($args);
  return (
    EVAL($scope => $method_args),
    CONS($inv),
    CMB9($scope => raw($self)),
  );
};

1;
