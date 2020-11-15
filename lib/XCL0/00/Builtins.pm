package XCL0::00::Builtins;

use XCL0::Exporter;
use Sub::Util qw(set_subname);

use XCL0::00::Runtime qw(
  panic mkv car cdr flatten
  eval0_00 progn set deref wutcol salis skvlis
  type rtype rtruep rboolp rcharsp
  raw list make_scope wrap combine
  $Scope_Fail
);

use Exporter 'import';

our @EXPORT = qw(builtin_scope builtin_list);

my %raw = (
  _getscope => sub ($scope, $) { $scope },
  _escape => sub ($scope, $lst) { car $lst },
  _id => wrap sub ($scope, $lst) { car $lst },
  #_listo => sub ($scope, $lst) { $lst },
  _list => wrap sub ($scope, $lst) { $lst },
  _type => wrap sub ($scope, $lst) { mkv String00 => chars => type(car $lst) },

  _panic => wrap sub ($scope, $lst) {
    my ($str, $v) = flatten $lst;
    panic 'Expected string, got' => $str unless type($str) eq 'String00';
    panic raw($str) => $v;
  },

  _eval0_00 => wrap sub ($scope, $lst) { eval0_00(car($lst), car($lst, 1)) },

  _set => do {
    my $code = XCL0::00::Runtime->can('set');
    wrap sub ($scope, $lst) { $code->(car($lst), car($lst, 1)) }
  },
  _progn => \&progn,
  _wutcol => sub ($scope, $lst) {
    panic 'Expected (if, then, else)' unless 3 == (my @args = flatten $lst);
    wutcol $scope, @args;
  },
  _salis => wrap sub ($scope, $lst) {
    panic 'Expected (key, alis, fallback)'
      unless 3 == (my @args = flatten $lst);
    salis($scope, @args);
  },
  _skvlis => wrap sub ($scope, $lst) {
    panic 'Expected (key, klis, vlis, fallback), got', $lst
      unless 4 == (my @args = flatten $lst);
    skvlis($scope, @args);
  },

  _eq_ref => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    mkv(Bool00 => bool => 0+!!($l == $r))
  },
  _eq_bool => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    panic 'Args must both be boolean, got' => list($l, $r)
      unless rboolp $l and rboolp $r;
    mkv(Bool00 => bool => 0+!!(raw($l) == raw($r)))
  },
  _eq_string => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    panic 'Args must both be strings, got' => list($l, $r)
      unless type($l) eq 'String00' and type($r) eq 'String00';
    mkv(Bool00 => bool => 0+!!(raw($l) eq raw($r)))
  },
  _gt_string => wrap sub ($scope, $lst) {
    my ($l, $r) = flatten $lst;
    panic 'Args must both be strings, got' => list($l, $r)
      unless type($l) eq 'String00' and type($r) eq 'String00';
    mkv(Bool00 => bool => 0+!!(raw($l) gt raw($r)))
  },
  _concat_string => wrap sub ($scope, $lst) {
    my ($l, $r) = (car($lst), car($lst, 1));
    panic 'Args must both be strings, got' => list($l, $r)
      unless type($l) eq 'String00' and type($r) eq 'String00';
    mkv(String00 => chars => raw($l).raw($r))
  },

  _rtype => wrap sub ($scope, $lst) { mkv String00 => chars => rtype(car $lst) },

  _rmkchars => wrap sub ($scope, $lst) {
    panic "Expected (type, value), got", $lst
      unless 2 == (my ($typep, $v) = flatten $lst);
    mkv(raw($typep), 'chars', raw($v));
  },
  _rmkcons => wrap sub ($scope, $lst) {
    panic "Expected (type, first, rest), got", $lst
      unless 3 == (my ($typep, @v) = flatten($lst));
    mkv(raw($typep), 'cons', @v);
  },
  _rmknil => wrap sub ($scope, $lst) {
    panic "Expected (type), got", $lst
      unless 1 == (my ($typep) = flatten $lst);
    mkv(raw($typep), 'nil');
  },
  _rtrue => sub ($, $) { mkv(Bool00 => bool => 1) },
  _rfalse => sub ($, $) { mkv(Bool00 => bool => 0) },
  (map {
    my $rtype = $_;
    "_rmk${rtype}" => wrap sub ($scope, $lst) {
      panic "Expected (type, value), got", $lst
        unless 2 == (my ($typep, $v) = flatten $lst);
      mkv(raw($typep), $rtype, $v);
    }
  } qw(var val)),
  (map {
    my $code = XCL0::00::Runtime->can("r${_}p");
    ("_r${_}?" => wrap sub ($scope, $lst) {
      mkv Bool00 => bool => 0+!!$code->(car $lst) 
    })
  } qw(cons nil chars bool native val var)),
  (map {
    my $code = XCL0::00::Runtime->can($_);
    ('_'.($_ =~ s/p$/?/r) => wrap set_subname 'opv_'.$_ => sub ($scope, $lst) { $code->(car $lst) })
  } qw(valp refp val deref car cdr)),
  # probably worth having but needs more thought
  #_combine => wrap sub ($scope, $lst) {
  #  combine($scope, uncons($lst));
  #},
  _wrap => wrap sub ($scope, $lst) {
    return mkv Apv00 => val => car $lst;
  },
  _scope0_00 => sub ($, $) { builtin_scope() },
);

my %cooked = map +($_ => mkv Fexpr00 => native => set_subname($_, $raw{$_})),
               keys %raw;

$cooked{_scope_fail} = $Scope_Fail;

sub builtin_list { sort keys %cooked }

sub builtin_scope {
  state $scope = make_scope \%cooked;
  mkv Scope00 => var => raw $scope;
}

1;
