package NXCL::01::CallMethod;

use NXCL::Exporter;
use NXCL::01::TypeFunctions qw(
  OpDictT NativeT
  make_List make_String
);

our @EXPORT = qw(call_method lookup_method);

sub call_method ($scope, $self, $methodp, $args. $kstack) {
  my ($method_name, $method_String) = (
    ref($methodp)
      ? (raw($methodp), $methodp)
      : ($methodp, make_String($methodp))
  );
  my $type = type($self);
  if (type($type) == OpDictT) {
    panic unless my $handler = raw($type)->{$method_name};
    if (type($handler) == NativeT) {
      return raw($handler)->($scope, $handler, $args, $kstack);
    }
    return (
      [ CMB9 => $scope, $handler, $args ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List($method_String) ],
    [ CMB6 => $scope, $args ],
    $kstack
  );
}

sub lookup_method ($scope, $self, $methodp, $kstack) {
  my ($method_name, $method_String) = (
    ref($methodp)
      ? (raw($methodp), $methodp)
      : ($methodp, make_String($methodp))
  );
  my $type = type($self);
  if (type($type) == OpDictT) {
    panic unless my $handler = raw($type)->{$method_name};
    return (
      [ JUST => make_Curry($handler, make_List($self)) ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List($method_String) ],
    [ CMB9 => $scope => make_Native(sub ($scope, $cmb, $args, $kstack) {
        make_Curry(uncons($args)[0], make_List($self))
    } ],
    $kstack
  );
}

1;
