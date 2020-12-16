package NXCL::01::CallT;

use NXCL::01::TypeExporter;

sub make ($call, $args) { _make ConsR ,=> $call, $args }

raw method evaluate => sub ($scope, $self, $, $kstack) {
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons([ CMB9 => $cdr ], $kstack),
  );
};

1;
