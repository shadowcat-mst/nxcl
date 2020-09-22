package XCL0::00::Builtins;

use Mojo::Base -strict, -signatures;

use XCL0::00::Runtime qw(
  mkv car cdr uncons flatten
  eval_inscope progn set
  type rboolp rcharsp
  raw make_scope wrap
);

use Exporter 'import';

our @EXPORT = qw(builtin_scope);

my %raw = (
  _setscope => wrap sub ($scope, $lst) {
    my $argscope = car $lst;
    set $scope => $argscope;
    return $argscope;
  },
  _getscope => wrap sub ($scope, $) { $scope },
  _wutcol => sub ($scope, $lst) {
    my ($if, $blocks) = uncons $lst;
    my ($then, $else) = uncons $blocks;
    my ($scope2, $res) = eval_inscope $scope, $if;
    if (rtruep $res) {
      return eval_inscope $scope2, $then;
    } else {
      return eval_inscope $scope2, $else;
    }
  },
  _eval_inscope => wrap \&eval_inscope,
  _rmkv => wrap sub ($scope, $lst) {
    my ($typep, $reprp, @v) = flatten($lst);
    mkv(raw($typep), raw($reprp), @v);
  },
  _type => wrap sub ($scope, $lst) { mkv String => chars => type(car $lst) },
  _rtype => wrap sub ($scope, $lst) { mkv String => chars => rtype(car $lst) },
  (map {
    my $code = XCL0::00::Runtime->can("r${_}p");
    ("_r${_}?" => wrap sub ($scope, $lst) {
      mkv Bool => bool => 0+!!$code->(car $lst) 
    })
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
    mkv(Bool => bool => 0+!!(raw($l) == raw($r)))
  },
  _eq_chars => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless rcharsp $l and rcharsp $r;
    mkv(Bool => bool => 0+!!(raw($l) eq raw($r)))
  },
  _gt_chars => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless rcharsp $l and rcharsp $r;
    mkv(Bool => bool => 0+!!(raw($l) gt raw($r)))
  },
  _string_concat => wrap sub ($scope, $lst) {
    my ($l, $r) = (car($lst), car($lst, 1));
    die unless type($l) eq 'String' and type($r) eq 'String';
    mkv(String => chars => raw($l).raw($r))
  },
);

my %cooked = map +($_ => mkv Native => native => $raw{$_}), keys %raw;

sub builtin_scope {
  make_scope \%cooked;
}

1;
