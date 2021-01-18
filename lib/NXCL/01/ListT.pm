package NXCL::01::ListT;

use NXCL::01::Utils qw(uncons flatten rconsp);
use NXCL::01::TypeExporter;

export make => sub (@members) { cons(@members, $NIL) };

export cons => sub (@members) {
  panic unless my $ret = pop @members;
  foreach my $m (reverse @members) {
    $ret = _make ConsR ,=> $m, $ret;
  }
  return $ret;
};

for (make_constant_combiner($NIL)) {
  static empty => $_;
  export empty => $_;
}

method first => sub ($scope, $self, $, $kstack) {
  panic unless rconsp $self;
  my ($first) = uncons $self;
  evaluate_to_value($scope, $first, $NIL, $kstack);
};

method rest => sub ($scope, $self, $, $kstack) {
  panic unless rconsp $self;
  my (undef, $rest) = uncons $self;
  evaluate_to_value($scope, $rest, $NIL, $kstack);
};

method evaluate => sub ($scope, $self, $, $kstack) {
  if (rnilp $self) {
    evaluate_to_value($scope, $self, $NIL, $kstack);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons_List([ ECDR => $scope => $cdr ], $kstack),
  );
};

# wrap method scan => '_scan';
# 
# raw method scan => sub ($scope, $args, $m, $kstack) {
#   my ($self, $scan_by, $accum) = flatten $args;
#   if (rnilp $self) {
#     return evaluate_to_value($scope, $accum, $kstack);
#   }
#   my ($car, $cdr) = uncons($self);
#   return (
#     [ CMB9 => $scope => make_List($accum, $car) => $scan_by ],
#     cons_List(
#       [ CMB6 => $scope => make_Curry(
#           make_Method($cdr, '_scan_step'), make_List($scan_by)
#       ) ],
#       $kstack
#     )
#   );
# };
# 
# raw method _scan_step => sub ($scope, $args, $m, $kstack) {
#   my ($self, $scan_by, $accum) = flatten $args;
#   return evaluate_to_value(
#     $scope,
#     make_LazyCons(
#       $accum,
#       make_Curry(
#         make_Method($self, '_scan'),
#         make_List($scan_by, $accum)
#       )
#     ),
#     $kstack,
#   );
# };

1;
