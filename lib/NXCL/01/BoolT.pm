package NXCL::01::BoolT;

use NXCL::01::TypeExporter;

export make => sub ($val) { _make BoolR ,=> 0+!!$val };

wrap method eq => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be bools' for grep $Types{Bool} ne $_, $l, $r;
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

static true => my $true = make_const_combiner(make(1));
static false => my $false = make_const_combiner(make(0));

export true => $true;
export false => $false;

1;
