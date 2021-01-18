package NXCL::01::Runtime;

use NXCL::Exporter;
use Scalar::Util qw(weaken);
use List::Util qw(reduce);
use NXCL::01::Utils qw(
  type
  uncons
  raw
  $NIL
);
use NXCL::01::Types qw(OpDict String List);

our @EXPORT_OK = qw(run_til_done);

sub take_step_EVAL ($scope, $value, $kstack) {
  my $type = type($value);
  #if ($Is_Literal{$type}) {
  #  return evaluate_to_value($scope, $value, $NIL, $kstack);
  #}
  if (type($type) == OpDictT) {
    my $handler = raw($type)->{'evaluate'};
    if (type($handler) == RawNativeT) {
      return raw($handler)->($scope, $value, $NIL, $kstack);
    }
    return (
      [ CMB9 => $scope, $handler, make_List($value) ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List(make_String('evaluate')) ],
    cons_List([ CMB6 => $scope, make_List($value) ], $kstack)
  );
}

sub take_step_CMB9 ($scope, $combiner, $args, $kstack) {
  my $type = type($combiner);
  if ($type == RawNativeT) {
    return raw($combiner)->($scope, $combiner, $args, $kstack);
  }
  if (type($type) == OpDictT) {
    my $handler = raw($type)->{'combine'};
    if (type($handler) == RawNativeT) {
      return raw($handler)->($scope, $combiner, $args, $kstack);
    }
    return (
      [ CMB9 => $scope, $handler, cons_List($combiner, $args) ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $type, make_List(String 'combine') ],
    cons_List([ CMB6 => $scope, cons_List($combiner, $args) ], $kstack)
  );
}

sub take_step_ECDR ($scope, $cdr, $car, $kstack) {
  return (
    [ EVAL => $scope => $cdr ],
    cons_List([ CONS => $scope => $car ], $kstack)
  );
}

sub take_step_CONS ($scope, $car, $cdr, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, cons_List($car, $cdr) ],
    $kdr
  );
}

sub take_step_JUMP ($scope, $to, $arg, $kstack) {
  my ($kar, $kdr) = uncons $to;
  return (
    (defined($arg) ? [ @$kar, $arg ] : $kar),
    $kdr
  );
}

sub take_step_MARK ($scope, $, $val, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, $val ],
    $kdr
  );
}

sub take_step ($prog, $kstack) {
  my ($op, $scope, $v1, $v2) = @$prog;
  if ($op eq 'EVAL') {
    return take_step_EVAL($scope, $v1, $kstack);
  }
  if ($op eq 'CMB9') {
    return take_step_CMB9($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'CMB6') {
    return take_step_CMB9($scope, $v2, $v1, $kstack);
  }
  if ($op eq 'ECDR') {
    return take_step_ECDR($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'CONS') {
    return take_step_CONS($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'JUMP') {
    return take_step_JUMP($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'MARK') {
    return take_step_MARK($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'HOST') {
    return [ $v1, $v2, $kstack ];
  }
  die "Unkown op type $op";
}

sub run_til_done ($prog, $kstack) {
  while ($kstack) {
    ($prog, $kstack) = take_step($prog, $kstack);
  }
  return $prog;
}

1;
