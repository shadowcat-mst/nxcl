package NXCL::01::BoolT;

use NXCL::01::Utils qw(mset panic raw flatten);
use NXCL::01::ReprTypes qw(BoolR);
use NXCL::01::TypePackage;

export make => \&make;

sub make ($val) { _make BoolR ,=> 0+!!$val };

wrap method eq => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be bools' unless mset($r) == $mset;
  return (
    [ JUST => make(raw($self) == raw($r)) ],
  );
};

method ifelse => sub ($scope, $cmb, $self, $args) {
  panic 'Wrong arg count' unless 2 ==
    (my ($then, $else) = flatten $args);
  return (
    [ EVAL => $scope => raw($self) ? $then : $else ],
  );
};

static true => sub { return ([ JUST => make(1) ], $_[-1]) };
static false => sub { return ([ JUST => make(0) ], $_[-1]) };

export true => sub { make(1) };
export false => sub { make(0) };

1;
