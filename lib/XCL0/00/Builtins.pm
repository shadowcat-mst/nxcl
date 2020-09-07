package XCL0::00::Builtins;

use XCL0::00::Runtime qw();

my %raw = (
  _setscope => wrap sub ($scope, $lst) {
    my $argscope = car $lst;
    return ($argscope, $argscope);
  }
);

my %normal = (
  _getscope => wrap sub ($scope, $) { $scope },
  _wutcol => sub ($scope, $lst) {
    my ($if, $blocks) = uncons $lst;
    my ($then, $else) = uncons $blocks;
    my ($scope2, $res) = eval_inscope $scope, $if;
    if (rtruep $res) {
      return eval_inscope $scope2, $then;
    } else {
      return eval_inscope $scope2, $false;
    }
  },
  _eval_inscope => wrap \&eval_inscope,
  _rmkv => wrap sub ($scope, $lst) {
    my ($typep, $reprp, @v) = flatten($lst);
    mkv(raw($typep), raw($reprp), @v);
  },
  _type => wrap sub ($scope, $lst) { type(car $lst) },
  (map {
    my $code = XCL0::00::Runtime->can("r${_}p");
    ("_r${_}?" => wrap sub ($scope, $lst) { $code->(car $lst) })
  } qw(cons nil chars bool native val var)),
  (map {
    my $code = XCL0::00::Runtime->can($_);
    ('_'.$_ => wrap sub ($scope, $lst) { $code->(car $lst) })
  } qw(valp refp val deref car cdr)),
  set => do {
    my $code = XCL0::00::Runtime->can('set');
    wrap sub ($scope, $lst) { $code->(car($lst), car($lst, 1)) }
  },
  _progn => \&progn,
  _eq_bool => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless rboolp $l and rboolp $r;
    raw($l) == raw($r)
  },
  _eq_chars => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless rcharsp $l and rcharsp $r;
    raw($l) eq raw($r)
  },
  _gt_chars => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless rcharsp $l and rcharsp $r;
    raw($l) gt raw($r)
  },
);

foreach my $name (sort keys %normal) {
  my $normal = $normal{$name};
  $raw{$name} = sub ($scope, $lst) { ($scope, $normal->($scope, $lst)) };
}
