package NXCL::CombineT;

use NXCL::Utils qw(uncons);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(make_List);
use NXCL::TypePackage;

export make => sub ($call, @args) { _make ConsR ,=> $call, make_List @args };
export cons => sub ($call, $args) { _make ConsR ,=> $call, $args };

method evaluate => sub ($scope, $cmb, $self, $args) {
  my ($call, $call_args) = uncons $self;
  return (
    [ EVAL => $scope => $call ],
    [ CMB6 => $scope => $call_args ],
  );
};

1;
