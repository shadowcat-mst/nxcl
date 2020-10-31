package XCL0::00::Builtins;

use Mojo::Base -strict, -signatures;
use Sub::Util qw(set_subname);

use XCL0::00::Runtime qw(
  mkv car cdr uncons flatten
  eval0_00 progn set deref
  type rtype rtruep rboolp rcharsp
  raw list make_scope wrap combine
);

use Exporter 'import';

our @EXPORT = qw(builtin_scope builtin_list);

my %raw = (
  _getscope => sub ($scope, $) { $scope },
  _escape => sub ($scope, $lst) { car $lst },
  _id => wrap sub ($scope, $lst) { car $lst },
  _list => wrap sub ($scope, $lst) { $lst },
  _type => wrap sub ($scope, $lst) { mkv String => chars => type(car $lst) },

  _wutcol => sub ($scope, $lst) {
    my ($if, $blocks) = uncons $lst;
    my ($then, $else) = uncons $blocks;
    my $res = eval0_00 $scope, $if;
    if (rtruep $res) {
      return eval0_00 $scope, $then;
    } else {
      return eval0_00 $scope, car $else;
    }
  },

  _eval0_00 => wrap sub ($scope, $lst) { eval0_00(car($lst), car($lst, 1)) },

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
  _concat_string => wrap sub ($scope, $lst) {
    my ($l, $r) = (car($lst), car($lst, 1));
    die unless type($l) eq 'String' and type($r) eq 'String';
    mkv(String => chars => raw($l).raw($r))
  },

  _rtype => wrap sub ($scope, $lst) { mkv String => chars => rtype(car $lst) },

  _rmkchars => wrap sub ($scope, $lst) {
    my ($typep, $v) = flatten $lst;
    mkv(raw($typep), 'chars', raw($v));
  },
  _rmkcons => wrap sub ($scope, $lst) {
    my ($typep, @v) = flatten($lst);
    mkv(raw($typep), 'cons', @v);
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
    ('_'.($_ =~ s/p$/?/r) => wrap set_subname 'opv_'.$_ => sub ($scope, $lst) { $code->(car $lst) })
  } qw(valp refp val deref car cdr)),
  _wrap => wrap sub ($scope, $lst) {
    my $opv = car $lst;
    my $apv = wrap sub ($scope, $lst) {
      combine($scope, $opv, $lst)
    };
    mkv Native => native => $apv;
  },
  _scope0_00 => sub ($, $) { builtin_scope() },
  _names0_00 => sub ($, $) {
    list map mkv(String => chars => $_), builtin_list()
  },
);

my %cooked = map +($_ => mkv Native => native => set_subname($_, $raw{$_})),
               keys %raw;

sub builtin_list { sort keys %cooked }

sub builtin_scope {
  make_scope \%cooked;
}

1;
