package NXCL::01::ObjectT;

use NXCL::01::TypeExporter;

# no sub make, I don't think creating anything of this type makes sense

sub bind_method ($scope, $, $args, $kstack) {
  my ($obj, $method) = uncons $args;
  evaluate_to_value(
    $scope, make_Curry($method, make_List($obj)), $NIL, $kstack
  );
}

our $BIND_METHOD = make_RawNative(\&bind_method);

raw method 'invoker-for' => \&invoker_for;

sub invoker_for ($scope, $self, $args, $kstack) {
  my ($method_String) = uncons $args;
  my $method_name = raw($method_String);
  my $type = type($self);
  if (type($type) == OpDictT) {
    panic unless my $method = raw($type)->{$method_name};
    return evaluate_to_value(
      $scope, make_Curry($method, make_List($self)), $NIL, $kstack
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List($method_String) ],
    cons_List(
      [ CONS => $scope => $self ],
      [ CMB9 => $scope => $BIND_METHOD ],
      $kstack
    )
  );
};

raw method 'invoke-method' => sub ($scope, $self, $args, $kstack) {
  my ($method_String, $method_args) = uncons $args;
  my $method_name = raw($method_String);
  my $type = type($self);
  if (type($type) == OpDictT) {
    panic unless my $method = raw($type)->{$method_name};
    return (
      [ $scope, CMB9 => $method, cons_List($self, $method_args) ]
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List($method_String) ],
    cons_List(
      [ CMB6 => $scope, cons_List($self, $method_args) ],
      $kstack
    )
  );
};

1;
