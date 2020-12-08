package NXCL::01::ListT;

use NXCL::00::Runtime qw(uncons flatten);
use NXCL::01::TypeExporter;

sub make (@members) {
  my $ret = mkv ListT ,=> 'nil';
  foreach my $m (reverse @members) {
    $ret = mkv ListT ,=> cons => $m, $ret;
  }
  return $ret;
}

thunk static empty => sub ($) { make() };

raw method evaluate => sub ($scope, $self, $, $kstack) {
  if (rnilp $self) {
    evaluate_to_value($scope, $self, $kstack);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons([ ECDR => $scope => $cdr ], $kstack),
  );
};

wrap method scan => '_scan';

raw method scan => sub ($scope, $args, $m, $kstack) {
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
};

raw method _scan_step => sub ($scope, $args, $m, $kstack) {
  my ($self, $scan_by, $accum) = flatten $args;
  return evaluate_to_value(
    $scope,
    LazyCons($accum, Curry(Method($self, '_scan'), List($scan_by, $accum))),
    $kstack,
  );
};

1;
