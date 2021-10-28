package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(object_is uncons raw rnilp);
use NXCL::MethodUtils;
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(Native_Inst make_List cons_List);
use if !__PACKAGE__->can('DEBUG'), constant => DEBUG => 0;

our @EXPORT_OK = qw(run_til_done);

sub take_method_step ($scope, $inv, $methodp, $args, $kstack) {
  return ($scope, call_method(
    $scope, $methodp, $args
  ), $kstack);
}

sub take_step_EVAL ($scope, $value, $kstack) {
  return take_method_step(
    $scope, $value, 'evaluate', make_List($value), $kstack
  );
}

sub take_step_CALL ($scope, $methodp, $args, $kstack) {
  return take_method_step(
    $scope, (uncons($args))[0], $methodp, $args, $kstack
  );
}

sub take_step_CMB9 ($scope, $cmb, $args, $kstack) {
  if (object_is $cmb, Native_Inst) {
    return ($scope, raw($cmb)->($scope, $cmb, $args), $kstack);
  }
  return take_method_step(
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
    # This code should probably be:
    # [ @$kar, $val ],
    # but I'm currently trying to get RunTrace to report things and
    # the $kar never gets re-used so we can go with this for the moment:
    do { push @$kar, $val; $kar },
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

sub take_step_RPLS ($, $scope, $kstack) {
  return ($scope, uncons($kstack));
}

sub take_step_OVER ($scope, $val, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return ($scope, $kar, JUST($val), $kdr);
}

our %step_func = map +($_ => __PACKAGE__->can("take_step_${_}")),
  @NXCL::OpUtils::OPNAMES;

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
  while (($scope, $prog, my @stack) = take_step($scope, $prog, $kstack)) {
    return ($scope, @$prog) unless @stack;
    $kstack = cons_List(@stack);
  }
  die "notreached";
}

1;
