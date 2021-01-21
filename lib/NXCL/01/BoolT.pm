package NXCL::01::BoolT;

use NXCL::01::Utils qw(type panic raw flatten make_const_method);
use NXCL::01::ReprTypes qw(BoolR);
use NXCL::01::TypeExporter;

export make => \&make;

sub make ($val) { _make BoolR ,=> 0+!!$val };

wrap method eq => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($self);
  panic 'Must be bools' unless type($r) == $type;
  return (
    [ JUST => make(raw($self) == raw($r)) ],
  );
}

method ifelse => sub ($scope, $cmb, $self, $args) {
  panic 'Wrong arg count' unless 2 ==
    my ($then, $else) = flatten $args;
  return (
    [ EVAL => $scope => raw($bool) ? $then : $else ],
  );
}

my $true = make(1);
my $false = make(0);

static true => sub { return ([ JUST => $true ], $_[-1]) };
static false => sub { return ([ JUST => $false ], $_[-1]) };

export true => sub { $true };
export false => sub { $false };

1;
