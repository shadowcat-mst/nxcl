package NXCL::BlockT;

use NXCL::ReprTypes qw(DictR);
use NXCL::Utils qw(raw);
use NXCL::TypePackage;

sub make ($scope, $body) {
  _make DictR ,=> {
    scope => $scope,
    body => $body,
  };
}

export make => \&make;

method combine => sub ($scope, $cmb, $self, $args) {
  my ($block_scope, $block_body) = @{raw($self)}{qw(scope body)};
  return (
    RPLS($block_scope),
    EVAL($block_body),
    OVER(),
    RPLS($scope)
  );
};

1;
