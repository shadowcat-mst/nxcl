package NXCL::01::MethodUtils;

use NXCL::Exporter;
use NXCL::01::Utils qw(panic mset raw);
use NXCL::01::TypeFunctions qw(
  OpDict_Inst Native_Inst
  make_List make_String make_Curry make_Native
);

our @EXPORT = qw(call_method lookup_method);

sub call_method ($scope, $self, $methodp, $args, $kstack) {
  my ($method_name, $method_String) = (
    ref($methodp)
      ? (raw($methodp), $methodp)
      : ($methodp, make_String($methodp))
  );
  my $mset = mset($self);
  if (mset($mset) == OpDict_Inst) {
    panic "No handler for ${method_name} on ".$mset
      ." (OpDict Type has methods: "
      .(join(', ', sort keys %{raw($mset)})||'(none)').")"
      unless my $handler = raw($mset)->{$method_name};
    if (mset($handler) == Native_Inst) {
      return raw($handler)->($scope, $handler, $args, $kstack);
    }
    return (
      [ CMB9 => $scope, $handler, $args ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $mset, make_List($method_String) ],
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
  my $mset = mset($self);
  if (mset($mset) == OpDict_Inst) {
    panic unless my $handler = raw($mset)->{$method_name};
    return (
      [ JUST => make_Curry($handler, make_List($self)) ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $mset, make_List($method_String) ],
    [ CMB9 => $scope => make_Native(sub ($scope, $cmb, $args, $kstack) {
        make_Curry((uncons($args))[0], make_List($self))
    }) ],
    $kstack
  );
}

1;
