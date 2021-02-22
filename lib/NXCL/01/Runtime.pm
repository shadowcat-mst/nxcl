package NXCL::01::Runtime;

use NXCL::Exporter;
use NXCL::01::Utils qw(mset uncons raw);
use NXCL::01::MethodUtils;
use NXCL::01::TypeFunctions qw(Native_Inst make_List cons_List);

our @EXPORT_OK = qw(run_til_done);

sub take_step_EVAL ($scope, $value, $kstack) {
  return call_method(
    $scope, $value, 'evaluate', make_List($value), $kstack
  );
}

sub take_step_CMB9 ($scope, $cmb, $args, $kstack) {
  if (mset($cmb) == Native_Inst) {
    return raw($cmb)->($scope, $cmb, $args, $kstack);
  }
  return call_method(
    $scope, $cmb, 'combine', cons_List($cmb, $args), $kstack
  );
}

sub take_step_CMB6 ($scope, $args, $cmb, $kstack) {
  return take_step_CMB9($scope, $cmb, $args, $kstack);
}

sub take_step_ECDR ($scope, $cdr, $car, $kstack) {
  return (
    [ EVAL => $scope => $cdr ],
    [ CONS => $car ],
    $kstack
  );
}

sub take_step_CONS ($car, $cdr, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, cons_List($car, $cdr) ],
    $kdr
  );
}

sub take_step_JUMP ($to, $arg, $kstack) {
  my ($kar, $kdr) = uncons $to;
  return (
    (defined($arg) ? [ @$kar, $arg ] : $kar),
    $kdr
  );
}

sub take_step_JUST ($val, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, $val ],
    $kdr
  );
}

sub take_step_DROP ($val, $kstack) {
  return $kstack;
}

sub take_step_MARK ($, $val, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, $val ],
    $kdr
  );
}

my %step_func = map +($_ => __PACKAGE__->can("take_step_${_}")),
  qw(EVAL CMB9 CMB6 ECDR CONS JUMP JUST DROP MARK);

sub take_step ($prog, $kstack) {
  my ($op, @v) = @$prog;
  if (my $step_func = $step_func{$op}) {
    return $step_func->(@v, $kstack);
  }
  if ($op eq 'HOST') {
    return [ $v[0], $kstack ];
  }
  die "Unkown op type $op";
}

sub run_til_done ($prog, $kstack) {
  while ((($prog, my @stack) = take_step($prog, $kstack)) >= 2) {
    $kstack = cons_List(@stack);
  }
  return $prog;
}

1;
