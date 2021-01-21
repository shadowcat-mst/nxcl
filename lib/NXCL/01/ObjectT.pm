package NXCL::01::ObjectT;

use NXCL::01::Utils qw(uncons raw type $NIL);
use NXCL::01::TypeFunctions qw(
  make_Native make_Curry make_List cons_List OpDictT
);
use NXCL::01::TypeExporter;

# no sub make, I don't think creating anything of this type makes sense

sub bind_method ($scope, $cmb, $args) {
  my ($obj, $method) = uncons $args;
  return ([ JUST => make_Curry($method, make_List($obj)) ]);
}

our $BIND_METHOD = make_Native(\&bind_method);

method 'invoker-for' => \&invoker_for;

sub invoker_for ($scope, $cmb, $self, $args) {
  my ($method_String) = uncons $args;
  my $method_name = raw($method_String);
  my $type = type($self);
  if (type($type) == OpDictT) {
    panic unless my $method = raw($type)->{$method_name};
    return ([ JUST => make_Curry($method, make_List($self)) ]);
  }
  return (
    [ CMB9 => $scope, $type, make_List($method_String) ],
    [ CONS => $scope => $self ],
    [ CMB9 => $scope => $BIND_METHOD ],
  );
};

method 'invoke-method' => \&invoke_method;

sub invoke_method ($scope, $cmb, $self, $args) {
  my ($method_String, $method_args) = uncons $args;
  my $method_name = raw($method_String);
  my $type = type($self);
  if (type($type) == OpDictT) {
    panic unless my $method = raw($type)->{$method_name};
    return (
      [ $scope, CMB9 => $method, cons_List($self, $method_args) ]
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List($method_String) ],
    [ CMB6 => $scope, cons_List($self, $method_args) ],
  );
};

1;
