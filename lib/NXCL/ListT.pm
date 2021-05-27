package NXCL::ListT;

use NXCL::Utils qw(
  uncons flatten rconsp rnilp panic rtype raw
);
use NXCL::ReprTypes qw(ConsR NilR);
use NXCL::TypeFunctions qw(make_String);
use NXCL::TypePackage;

export make => \&make;

sub make (@members) { cons(@members, _make(NilR)) };

export cons => \&cons;

sub cons (@members) {
  panic unless my $ret = pop @members;
  foreach my $m (reverse @members) {
    $ret = _make ConsR ,=> $m, $ret;
  }
  return $ret;
}

static empty => sub { [ JUST => _make(NilR) ] };
export empty => sub { _make(NilR) };

method to_xcl_string => sub ($scope, $cmb, $self, $) {
  return ([ CALL => $scope => '_to_xcl_string' => make($self) ]);
};

method _to_xcl_string => sub ($scope, $cmb, $self, $args) {
  if (rnilp($self)) {
    return ([ JUST make_String(
      '('.join(', ', map raw($_), reverse flatten $args).')'
    )]);
  }
  my ($car, $cdr) = uncons($self);
  return (
    [ CALL => $scope => 'to_xcl_string' => make($car) ],
    [ SNOC => $args ],
    [ CONS => $cdr ],
    [ CALL => $scope => '_to_xcl_string' ],
  );
};

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

wrap method concat => sub ($scope, $cmb, $self, $args) {
  my ($concat) = uncons($args);
  return ([
    JUST => cons(flatten($self), $concat)
  ]);
};

1;
