package NXCL::01::BoolT;

use NXCL::01::Utils qw(type panic raw flatten make_const_combiner);
use NXCL::01::ReprTypes qw(BoolR);
use NXCL::01::TypeFunctions qw(BoolT);
use NXCL::01::TypeExporter;

export make => \&make;

sub make ($val) { _make BoolR ,=> 0+!!$val };

wrap method eq => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be bools' for grep type($_) ne BoolT, $l, $r;
  return make(raw($l) == raw($r));
}

method ifelse => sub ($scope, $args, $, $kstack) {
  panic 'Wrong arg count' unless 3 ==
    my ($bool, $then, $else) = flatten $args;
  return (
    [ EVAL => $scope => raw($bool) ? $then : $else ],
    $kstack,
  );
}

static true => make_const_combiner(my $true = make(1));
static false => make_const_combiner(my $false = make(0));

export true => sub { $true };
export false => sub { $false };

1;
