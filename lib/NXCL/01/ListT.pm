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

method first => sub ($scope, $cmb, $self, $args) {
  panic unless rconsp $self;
  my ($first) = uncons $self;
  return ([ JUST => $first ]);
};

method rest => sub ($scope, $cmb, $self, $args) {
  panic unless rconsp $self;
  my (undef, $rest) = uncons $self;
  return ([ JUST => $rest ]);
};

method evaluate => sub ($scope, $cmb, $self, $args) {
  if (rnilp $self) {
    return ([ JUST => $self ]);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    [ ECDR => $scope => $cdr ],
  );
};

1;
