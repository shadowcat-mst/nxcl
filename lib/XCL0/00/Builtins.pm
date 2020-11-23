package XCL0::00::Builtins;

use XCL0::Exporter;
use Sub::Util qw(set_subname);

use XCL0::00::Runtime qw(
  debug panic mkv car cdr flatten set
  eval0_00 progn set deref wutcol salis skvlis
  type rtype rtruep rboolp rcharsp
  raw list make_scope wrap combine
);

use Exporter 'import';

our @EXPORT = qw(builtin_scope builtin_list);

sub _getscope ($scope, $) { $scope }

sub _escape ($scope, $lst) { car $lst }

sub __id ($scope, $lst) { car $lst }

sub __list ($scope, $lst) { $lst }

sub __type ($scope, $lst) { mkv String00 => chars => type(car $lst) }

sub __debug ($scope, $lst) { debug(flatten $lst) }

sub __panic ($scope, $lst) {
  my ($str, $v) = flatten $lst;
  panic 'Expected string, got' => $str unless type($str) eq 'String00';
  panic raw($str) => $v;
}

sub __eval0_00 ($scope, $lst) { eval0_00(car($lst), car($lst, 1)) }

sub __set ($scope, $lst) { set(car($lst), car($lst, 1)) }

sub _progn ($scope, $lst) { progn($scope, $lst) }

sub _wutcol ($scope, $lst) {
  panic 'Expected (if, then, else), got' unless 3 == (my @args = flatten $lst);
  wutcol $scope, @args;
}

sub __salis ($scope, $lst) {
  panic 'Expected (key, alis, fallback), got'
    unless 3 == (my @args = flatten $lst);
  salis($scope, @args);
}

sub __skvlis ($scope, $lst) {
  panic 'Expected (key, klis, vlis, fallback), got', $lst
    unless 4 == (my @args = flatten $lst);
  skvlis($scope, @args);
}

sub __eq_ref ($scope, $lst) {
  my ($l, $r) = flatten $lst;
  mkv(Bool00 => bool => 0+!!($l == $r))
}

sub __eq_bool ($scope, $lst) {
  my ($l, $r) = flatten $lst;
  panic 'Args must both be boolean, got' => list($l, $r)
    unless rboolp $l and rboolp $r;
  mkv(Bool00 => bool => 0+!!(raw($l) == raw($r)))
}

sub __eq_string ($scope, $lst) {
  my ($l, $r) = flatten $lst;
  panic 'Args must both be strings, got' => list($l, $r)
    unless type($l) eq 'String00' and type($r) eq 'String00';
  mkv(Bool00 => bool => 0+!!(raw($l) eq raw($r)))
}

sub __gt_string ($scope, $lst) {
  my ($l, $r) = flatten $lst;
  panic 'Args must both be strings, got' => list($l, $r)
    unless type($l) eq 'String00' and type($r) eq 'String00';
  mkv(Bool00 => bool => 0+!!(raw($l) gt raw($r)))
}

sub __concat_string ($scope, $lst) {
  my ($l, $r) = (car($lst), car($lst, 1));
  panic 'Args must both be strings, got' => list($l, $r)
    unless type($l) eq 'String00' and type($r) eq 'String00';
  mkv(String00 => chars => raw($l).raw($r))
}

sub __rtype ($scope, $lst) { mkv String00 => chars => rtype(car $lst) }

sub __rmkchars ($scope, $lst) {
  panic "Expected (type, value), got", $lst
    unless 2 == (my ($typep, $v) = flatten $lst);
  mkv(raw($typep), 'chars', raw($v));
}

sub __rmkcons ($scope, $lst) {
  panic "Expected (type, first, rest), got", $lst
    unless 3 == (my ($typep, @v) = flatten($lst));
  mkv(raw($typep), 'cons', @v);
}

sub __rmknil ($scope, $lst) {
  panic "Expected (type), got", $lst
    unless 1 == (my ($typep) = flatten $lst);
  mkv(raw($typep), 'nil');
}

sub _rtrue ($, $) { mkv(Bool00 => bool => 1) }
sub _rfalse ($, $) { mkv(Bool00 => bool => 0) }

my %computed = (
  (map {
    my $rtype = $_;
    "__rmk${rtype}" => sub ($scope, $lst) {
      panic "Expected (type, value), got", $lst
        unless 2 == (my ($typep, $v) = flatten $lst);
      mkv(raw($typep), $rtype, $v);
    }
  } qw(var val)),
  (map {
    my $code = XCL0::00::Runtime->can("r${_}p");
    ("__r${_}?" => sub ($scope, $lst) {
      mkv Bool00 => bool => 0+!!$code->(car $lst) 
    })
  } qw(cons nil chars bool native val var)),
  (map {
    my $code = XCL0::00::Runtime->can($_);
    ('__'.($_ =~ s/p$/?/r) => sub ($scope, $lst) { $code->(car $lst) })
  } qw(valp refp val deref car cdr)),
  # probably worth having but needs more thought
  #_combine => wrap sub ($scope, $lst) {
  #  combine($scope, uncons($lst));
  #},
);

foreach my $name (sort keys %computed) {
  no strict 'refs';
  *$name = set_subname($name, $computed{$name});
}

sub __wrap ($scope, $lst) {
  return mkv Apv00 => val => car $lst;
}

sub _scope0_00 ($, $) { builtin_scope() }

my %cooked = (
  map {
    my $sub = __PACKAGE__->can($_);
    my $wrap = (my $name = $_) =~ s/^__/_/;
    ($name => (
      $wrap
        ? mkv(Apv00 => val => mkv(Fexpr00 => native => $sub))
        : mkv(Fexpr00 => native => $sub)))
  } grep /^_/, keys %XCL0::00::Builtins::
);

sub builtin_list { sort keys %cooked }

sub builtin_scope {
  state $scope = make_scope \%cooked;
  mkv Scope00 => var => raw $scope;
}

1;
