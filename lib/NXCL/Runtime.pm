package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(mset uncons raw rnilp);
use NXCL::MethodUtils;
use NXCL::TypeFunctions qw(Native_Inst make_List cons_List);
use if !__PACKAGE__->can('DEBUG'), constant => DEBUG => 0;

our @EXPORT_OK = qw(run_til_done);

sub take_step_EVAL ($scope, $value, $kstack) {
  return call_method(
    $scope, $value, 'evaluate', make_List($value), $kstack
  );
}

sub take_step_CALL ($scope, $methodp, $args, $kstack) {
  return call_method(
    $scope, (uncons($args))[0], $methodp, $args, $kstack
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
  if (rnilp $cdr) {
    return (
      [ JUST => make_List($car) ],
      $kstack
    );
  }
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

sub take_step_SNOC ($cdr, $car, $kstack) {
  take_step_CONS($car, $cdr, $kstack);
}

sub take_step_JUMP ($to, $arg, $kstack) {
  raw($arg) ? $to : $kstack;
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

our %step_func = map +($_ => __PACKAGE__->can("take_step_${_}")),
  qw(EVAL CALL CMB9 CMB6 ECDR CONS SNOC JUMP JUST DROP);

sub take_step ($prog, $kstack) {
  DEBUG and DEBUG_WARN($prog, $kstack);
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
