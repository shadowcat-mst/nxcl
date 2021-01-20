package NXCL::01::ListT;

use NXCL::01::Utils qw(
  uncons flatten rconsp panic make_const_combiner
);
use NXCL::01::ReprTypes qw(ConsR NilR);
use NXCL::01::TypeExporter;

our $NIL = _make NilR;

export make => sub (@members) { cons(@members, $NIL) };

export cons => \&cons;

sub cons (@members) {
  panic unless my $ret = pop @members;
  foreach my $m (reverse @members) {
    $ret = _make ConsR ,=> $m, $ret;
  }
  return $ret;
}

static empty => make_const_combiner($NIL);
export empty => sub { $NIL };

method first => sub ($scope, $self, $, $kstack) {
  panic unless rconsp $self;
  my ($first) = uncons $self;
  return ([ JUST => $scope => $first ], $kstack);
};

method rest => sub ($scope, $self, $, $kstack) {
  panic unless rconsp $self;
  my (undef, $rest) = uncons $self;
  return ([ JUST => $scope => $rest ], $kstack);
};

method evaluate => sub ($scope, $self, $, $kstack) {
  if (rnilp $self) {
    return ([ JUST => $scope => $self ], $kstack);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons([ ECDR => $scope => $cdr ], $kstack),
  );
};

1;
