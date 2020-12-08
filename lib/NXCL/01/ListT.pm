package NXCL::01::ListT;

use NXCL::00::Runtime qw(uncons flatten);
use NXCL::01::TypeExporter;

sub empty_List :Thunk ($scope) { List() }

sub List (@members) {
  my $ret = nil;
  foreach my $m (reverse @members) {
    $ret = Cons $m, $ret;
  }
  return $ret;
}

sub List_evaluate :Raw ($scope, $self, $, $kstack) {
  if (rnilp $self) {
    evaluate_to_value($scope, $self, $kstack);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons([ ECDR => $scope => $cdr ], $kstack),
  );
}

sub List_map :Apv :Raw ($scope, $args, $m, $kstack) {
  my ($self, $map_by) = flatten $args;
  if (rnilp $self) {
    return evaluate_to_value($scope, $self, $kstack);
  }
  my ($car, $cdr) = uncons($self);
  return (
    [ CMB9 => $scope => List1($car) => $map_by ],
    cons(
      [ CMB6 => $scope => Curry(Method($cdr, '_map_step'), List1 $map_by) ],
      $kstack
    )
  );
}

sub List__map_step :Raw ($scope, $args, $m, $kstack) {
  my ($self, $map_by, $car) = flatten $args;
  return evaluate_to_value(
    $scope,
    LazyCons($car, Curry(Method($self, 'map'), List1 $map_by)),
    $kstack,
  );
}

sub List_mapl :Apv :Raw ($scope, $args, $m, $kstack) {
  my ($self, $map_by) = flatten $args;
  if (rnilp $self) {
    return evaluate_to_value($scope, $self, $kstack);
  }
  my ($car, $cdr) = uncons($self);
  return (
    [ CMB9 => $scope => List1($car) => $map_by ],
    cons(
      [ CMB6 => $scope => Curry(Method($cdr, '_mapl_step'), List1 $map_by) ],
      $kstack
    )
  );
}

sub List__mapl_step :Raw ($scope, $args, $m, $kstack) {
  my ($self, $map_by, $car) = flatten $args;
  return evaluate_to_value(
    $scope,
    FlatCons(
      $car,
      Curry(Method($self, 'mapl'), List1 $map_by)),
    ),
    $kstack,
  );
}

sub List_scan :Apv :Raw ($scope, $args, $m, $kstack) {
  my ($self, $scan_by, $accum) = flatten $args;
  if (rnilp $self) {
    return evaluate_to_value($scope, $accum, $kstack);
  }
  my ($car, $cdr) = uncons($self);
  return (
    [ CMB9 => $scope => List($accum, $car) => $scan_by ],
    cons(
      [ CMB6 => $scope => Curry(Method($cdr, '_scan_step'), List1 $scan_by) ],
      $kstack
    )
  );
}

sub List__scan_step :Raw ($scope, $args, $m, $kstack) {
  my ($self, $scan_by, $accum) = flatten $args;
  return evaluate_to_value(
    $scope,
    LazyCons($accum, Curry(Method($self, 'scan'), List($scan_by, $accum))),
    $kstack,
  );
}

sub List_reduce :Apv :Raw ($scope, $args, $m, $kstack) {
  my ($self, $reduce_by, $accum) = flatten $args;
  if (rnilp $self) {
    return evaluate_to_value($scope, $accum, $kstack);
  }
  my ($car, $cdr) = uncons($self);
  return (
    [ CMB9 => $scope => List($accum, $car) => $reduce_by ],
    Cons(
      [ CMB6 => $scope =>
          Curry(Method($cdr, '_reduce_step'),
          List1 $reduce_by) ],
      $kstack
    )
  );
}

sub List__reduce_step :Raw ($scope, $args, $m, $kstack) {
  my ($self, $reduce_by, $val) = flatten $args;
  return (
    [ CMB6 => $scope => Method($self, 'reduce') => List($reduce_by, $val) ],
    $kstack,
  );
}

1;
