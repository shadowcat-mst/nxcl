package XCL0::00::Builtins;

use Mojo::Base -strict, -signatures;

use XCL0::00::Runtime qw(
  mkv car cdr uncons flatten
  eval_inscope progn set deref
  type rtype rtruep rboolp rcharsp
  raw make_scope wrap
);

use Exporter 'import';

our @EXPORT = qw(builtin_scope);

my %raw = (
  _getscope => sub ($scope, $) { $scope },
  _escape => sub ($scope, $lst) { car $lst },
  _id => wrap sub ($scope, $lst) { car $lst },
  _list => wrap sub ($scope, $lst) { $lst },
  _type => wrap sub ($scope, $lst) { mkv String => chars => type(car $lst) },

  _wutcol => sub ($scope, $lst) {
    my ($if, $blocks) = uncons $lst;
    my ($then, $else) = uncons $blocks;
    my $res = eval_inscope $scope, $if;
    if (rtruep $res) {
      return eval_inscope $scope, $then;
    } else {
      return eval_inscope $scope, car $else;
    }
  },

  _eval_inscope => wrap \&eval_inscope,

  _wrap => wrap sub ($scope, $lst) {
    mkv Native => native => wrap(raw(car $lst))
  },
  _set => do {
    my $code = XCL0::00::Runtime->can('set');
    wrap sub ($scope, $lst) { $code->(car($lst), car($lst, 1)) }
  },
  _progn => \&progn,
  _eq_bool => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless rboolp $l and rboolp $r;
    mkv(Bool => bool => 0+!!(raw($l) == raw($r)))
  },
  _eq_string => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless type($l) eq 'String' and type($r) eq 'String';
    mkv(Bool => bool => 0+!!(raw($l) eq raw($r)))
  },
  _gt_string => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    die unless type($l) eq 'String' and type($r) eq 'String';
    mkv(Bool => bool => 0+!!(raw($l) gt raw($r)))
  },
  _string_concat => wrap sub ($scope, $lst) {
    my ($l, $r) = (car($lst), car($lst, 1));
    die unless type($l) eq 'String' and type($r) eq 'String';
    mkv(String => chars => raw($l).raw($r))
  },

  _rtype => wrap sub ($scope, $lst) { mkv String => chars => rtype(car $lst) },

  _rmkchars => wrap sub ($scope, $lst) {
    my ($typep, $v) = flatten $lst;
    mkv(raw($typep), 'chars', raw($v));
  },
  _rmkref => wrap sub ($scope, $lst) {
    my ($typep, $reprp, @v) = flatten($lst);
    mkv(raw($typep), raw($reprp), @v);
  },
  _rmknil => wrap sub ($scope, $lst) {
    mkv(raw(car($lst)), 'nil');
  },
  _rtrue => sub ($, $) { mkv(Bool => bool => 1) },
  _rfalse => sub ($, $) { mkv(Bool => bool => 0) },
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
  _wrap => wrap sub ($scope, $lst) {
    mkv Native => native => wrap(raw(car $lst))
  },
);

my %cooked = map +($_ => mkv Native => native => $raw{$_}), keys %raw;

sub builtin_scope {
  make_scope \%cooked;
}

1;
