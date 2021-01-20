package NXCL::01::CombineT;

use NXCL::01::Utils qw(uncons);
use NXCL::01::ReprTypes qw(ConsR);
use NXCL::01::TypeFunctions(cons_List);
use NXCL::01::TypeExporter;

export make => sub ($call, $args) { _make ConsR ,=> $call, $args };

method evaluate => sub ($scope, $self, $, $kstack) {
  my ($call, $args) = uncons $self;
  return (
    [ EVAL => $scope => $call ],
    cons_List([ CMB6 => $args ], $kstack),
  );
};

1;
