package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(mset uncons raw rnilp);
use NXCL::MethodUtils;
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(Native_Inst make_List cons_List);
use if !__PACKAGE__->can('DEBUG'), constant => DEBUG => 0;

our @EXPORT_OK = qw(run_til_done);

sub step_call_method ($scope, $inv, $methodp, $args, $kstack) {
  return ($scope, call_method(
    $scope, $inv, $methodp, $args
  ), $kstack);
}

sub take_step_EVAL ($scope, $value, $kstack) {
  return step_call_method(
    $scope, $value, 'evaluate', make_List($value), $kstack
  );
}

sub take_step_CALL ($scope, $methodp, $args, $kstack) {
  return step_call_method(
    $scope, (uncons($args))[0], $methodp, $args, $kstack
  );
}

sub take_step_CMB9 ($scope, $cmb, $args, $kstack) {
  if (mset($cmb) == Native_Inst) {
    return ($scope, raw($cmb)->($scope, $cmb, $args), $kstack);
  }
  return step_call_method(
    $scope, $cmb, 'combine', cons_List($cmb, $args), $kstack
  );
}

sub take_step_CMB6 ($scope, $args, $cmb, $kstack) {
  return take_step_CMB9($scope, $cmb, $args, $kstack);
}

sub take_step_ECDR ($scope, $cdr, $car, $kstack) {
  if (rnilp $cdr) {
    return (
      $scope,
      JUST(make_List($car)),
      $kstack
    );
  }
  return (
    $scope,
    EVAL($cdr),
    CONS($car),
    $kstack
  );
}

sub take_step_JUST ($scope, $val, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    $scope,
    [ @$kar, $val ],
    $kdr
  );
}

sub take_step_CONS ($scope, $car, $cdr, $kstack) {
  take_step_JUST($scope, cons_List($car, $cdr), $kstack);
}

sub take_step_SNOC ($scope, $cdr, $car, $kstack) {
  take_step_CONS($scope, $car, $cdr, $kstack);
}

#sub take_step_JUMP ($to, $arg, $kstack) {
#  raw($arg) ? $to : $kstack;
#}

sub take_step_DROP ($scope, $val, $kstack) {
  return ($scope, uncons($kstack));
}

our %step_func = map +($_ => __PACKAGE__->can("take_step_${_}")),
  qw(EVAL CALL CMB9 CMB6 ECDR JUST CONS SNOC DROP);

sub take_step ($scope, $prog, $kstack) {
  DEBUG and DEBUG_WARN($prog, $kstack);
  my ($op, @v) = @$prog;
  if (my $step_func = $step_func{$op}) {
    return $step_func->($scope, @v, $kstack);
  }
  if ($op eq 'HOST') {
    return ($scope, [ $v[0], $kstack ]);
  }
  die "Unkown op type $op";
}

sub run_til_done ($scope, $prog, $kstack) {
  while ((($scope, $prog, my @stack) = take_step($scope, $prog, $kstack)) >= 3) {
    $kstack = cons_List(@stack);
  }
  return ($scope, @$prog);
}

1;
