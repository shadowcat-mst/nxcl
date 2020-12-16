package NXCL::01::ListT;

use NXCL::00::Runtime qw(uncons flatten);
use NXCL::01::TypeExporter;

sub make (@members) {
  my $ret = _make NilR;
  foreach my $m (reverse @members) {
    $ret = _make ConsR ,=> $m, $ret;
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
    [ CMB9 => $scope => make_List($accum, $car) => $scan_by ],
    cons(
      [ CMB6 => $scope => make_Curry(
          make_Method($cdr, '_scan_step'), make_List($scan_by)
      ) ],
      $kstack
    )
  );
};

raw method _scan_step => sub ($scope, $args, $m, $kstack) {
  my ($self, $scan_by, $accum) = flatten $args;
  return evaluate_to_value(
    $scope,
    make_LazyCons(
      $accum,
      make_Curry(
        make_Method($self, '_scan'),
        make_List($scan_by, $accum)
      )
    ),
    $kstack,
  );
};

1;
