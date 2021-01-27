package NXCL::01::Runtime;

use NXCL::Exporter;
use Scalar::Util qw(weaken);
use List::Util qw(reduce);
use NXCL::01::Utils qw(
  type
  uncons
  raw
);
use NXCL::01::MethodUtils;
use NXCL::01::TypeFunctions qw(
  OpDictT NativeT
  make_List cons_List make_String
);

our @EXPORT_OK = qw(run_til_done);

sub take_step_EVAL ($scope, $value, $kstack) {
  return call_method(
    $scope, $value, 'evaluate', make_List($value), $kstack
  );
}

sub take_step_CMB9 ($scope, $combiner, $args, $kstack) {
  my $type = type($combiner);
  if ($type == NativeT) {
    return raw($combiner)->($scope, $combiner, $args, $kstack);
  }
  return call_method(
    $scope, $combiner, 'combine', make_Cons($combiner, $args), $kstack
  );
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

sub take_step_MARK ($, $val, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, $val ],
    $kdr
  );
}

sub take_step ($prog, $kstack) {
  my ($op, @v) = @$prog;
  if ($op eq 'EVAL') {
    return take_step_EVAL(@v, $kstack);
  }
  if ($op eq 'CMB9') {
    return take_step_CMB9(@v, $kstack);
  }
  if ($op eq 'CMB6') {
    my ($scope, $args, $cmb) = @v;
    return take_step_CMB9($scope, $cmb, $args, $kstack);
  }
  if ($op eq 'ECDR') {
    return take_step_ECDR(@v, $kstack);
  }
  if ($op eq 'CONS') {
    return take_step_CONS(@v, $kstack);
  }
  if ($op eq 'JUMP') {
    return take_step_JUMP(@v, $kstack);
  }
  if ($op eq 'MARK') {
    return take_step_MARK(@v, $kstack);
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
