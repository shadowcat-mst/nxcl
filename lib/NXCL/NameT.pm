package NXCL::NameT;

use NXCL::Utils qw(mset object_is raw panic);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(
  make_String make_List cons_List empty_List
);
use NXCL::MethodUtils qw(call_method);
use NXCL::TypePackage;

export make => \&make;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $cmb, $self, $args) {
  return call_method(
    $scope, get_value_for_name => make_List($scope, $self)
  );
};

method assign_value => sub ($scope, $cmb, $self, $args) {
  return JUST empty_List if raw($self) eq '$';
  my ($new_value) = uncons($args);
  return call_method(
    $scope, set_value_for_name =>
      make_List $scope, $self, $new_value
  );
};

1;
