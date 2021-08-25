package NXCL::BlockProtoT;

use NXCL::Utils qw(raw);
use NXCL::TypeFunctions qw(make_List make_Block);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

export make => sub ($call) { _make ValR ,=> $call };

method but_bind_scope => sub ($scope, $cmb, $self, $args) {
  my ($bind) = uncons($args);
  return JUST make_Block $bind, raw($self);
};

method evaluate => sub ($scope, $cmb, $self, $args) {
  return JUST make_Block $scope, raw($self);
};

method combine => sub ($scope, $cmb, $self, $args) {
  my $block_body = raw($self);
  return CMB9(make_Block($scope, raw($self)), $args);
};

1;
