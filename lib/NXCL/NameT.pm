package NXCL::NameT;

use NXCL::Utils qw(mset object_is raw panic);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(
  make_String make_List
);
use NXCL::MethodUtils qw(call_method);
use NXCL::TypePackage;

export make => \&make;

sub make ($name) { _make CharsR ,=> $name }

method evaluate => sub ($scope, $cmb, $self, $args) {
  return call_method(
    $scope, $scope,
    combine => make_List($scope, make_String raw($self))
  );
};

1;
