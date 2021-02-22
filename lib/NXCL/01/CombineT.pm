package NXCL::01::CombineT;

use NXCL::01::Utils qw(uncons);
use NXCL::01::ReprTypes qw(ConsR);
use NXCL::01::TypePackage;

export make => sub ($call, $args) { _make ConsR ,=> $call, $args };

method evaluate => sub ($scope, $cmb, $self, $args) {
  my ($call, $call_args) = uncons $self;
  return (
    [ EVAL => $scope => $call ],
    [ CMB6 => $call_args ],
  );
};

1;
