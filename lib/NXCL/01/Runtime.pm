package NXCL::01::Runtime;

use NXCL::Exporter;
use Scalar::Util qw(weaken);
use List::Util qw(reduce);
use NXCL::00::Runtime qw(
  mkv
  type
  uncons
  raw
);
use NXCL::01::Utils qw(
  cons
  list1
);
use NXCL::01::Types qw(
  Apv
  Call
  Int
  Native
  List
  OpDict
  Scope
  Bool
  Name
  RawNative
  String
  Val
);

sub take_step_EVAL ($scope, $value, $kstack) {
  my $type = type($value);
  if (type($type) == OpDictT) {
    my $handler = raw($type)->{'evaluate'};
    if (type($handler) == RawNativeT) {
      return $handler->[1][1]($scope, $value, undef, $kstack);
    }
    return (
      [ CMB9 => $scope, list1($value), $handler ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, list1(String 'evaluate'), $type ],
    cons([ CMB9 => $scope, list1($value) ], $kstack)
  );
}

sub take_step_CMB9 ($scope, $args, $combiner, $kstack) {
  my $type = type($combiner);
  if (type($type) == OpDictT) {
    my $handler = raw($type)->{'combine'};
    if (type($handler) == RawNativeT) {
      return $handler->[1][1]($scope, $args, $combiner, $kstack);
    }
    return (
      [ CMB9 => $scope, cons($combiner, $args), $handler ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, list1(String 'combine'), $type ],
    cons([ CMB9 => $scope, cons($combiner, $args) ], $kstack)
  );
}

sub take_step_ECDR ($scope, $cdr, $car, $kstack) {
  return (
    [ EVAL => $scope => $cdr ],
    cons([ CONS => $scope => $car ], $kstack)
  );
}

sub take_step_CONS ($scope, $car, $cdr, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  # Assume the newly created pair should be the same type as the cdr rather
  # than a plain List; this may or may not be a good idea and once we know
  # this comment should be replaced by an explanation as to which and why.
  return (
    [ @$kar, mkv(type($cdr) => ConsR ,=> $car, $cdr) ],
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
  if ($op eq 'DONE') {
    return $v1;
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
