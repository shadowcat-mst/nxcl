package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(object_is uncons raw rnilp);
use NXCL::MethodUtils;
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(Native_Inst make_List cons_List);
use if !__PACKAGE__->can('DEBUG'), constant => DEBUG => 0;

our @EXPORT_OK = qw(run_til_host);

sub take_step_EVAL ($cxs, $opq, $value) {
  my $scope = $cxs->[-1][1];
  push @$opq, reverse
    call_method($scope, evaluate => make_List($value));
}

sub take_step_CALL ($cxs, $opq, $methodp, $args) {
  my $scope = $cxs->[-1][1];
  push @$opq, reverse
    call_method($scope, $methodp, $args);
}

sub take_step_CMB9 ($cxs, $opq, $cmb, $args) {
  my $scope = $cxs->[-1][1];
  push @$opq, reverse(
    object_is($cmb, Native_Inst)
      ? raw($cmb)->($scope, $cmb, $args)
      : call_method($scope, combine => cons_List($cmb, $args))
  );
}

sub take_step_CMB6 ($cxs, $opq, $args, $cmb) {
  take_step_CMB9($cxs, $opq, $cmb, $args);
}

sub take_step_ECDR ($cxs, $opq, $cdr, $car) {
  push @$opq, reverse(
    rnilp($cdr)
      ? JUST(make_List($car))
      : (EVAL($cdr), CONS($car))
  );
}

sub take_step_JUST ($cxs, $opq, $val) {
  push @{$opq->[-1]}, $val;
}

sub take_step_CONS ($cxs, $opq, $car, $cdr) {
  push @{$opq->[-1]}, cons_List($car, $cdr);
}

sub take_step_SNOC ($cxs, $opq, $cdr, $car) {
  push @{$opq->[-1]}, cons_List($car, $cdr);
}

sub take_step_DROP { }

sub take_step_OVER ($cxs, $opq, $count, $val) {
  splice @$opq, -$count, 0, JUST($val);
}

sub take_step_ECTX ($cxs, $opq, $thing, $count, $scope) {
  push @$cxs, [
     cons_List($thing, $cxs->[-1][0]),
     $scope,
     scalar(@$opq) - $count,
  ];
}

sub take_step_LCTX ($cxs, $opq, $val) {
  pop @$cxs;
  push @{$opq->[-1]}, $val;
}

our %step_func = map +($_ => __PACKAGE__->can("take_step_${_}")),
  @NXCL::OpUtils::OPNAMES;

sub take_step ($cxs, $opq) {
  DEBUG and DEBUG_WARN($cxs, $opq);
  my ($op, @v) = @{pop @$opq};
  die "Unkown op type $op" unless my $step_func = $step_func{$op};
  $step_func->($cxs, $opq, @v);
  return;
}

sub run_til_host ($cxs, $opq) {
  while ($opq->[-1][0] ne 'HOST') {
    take_step($cxs, $opq);
    DEBUG and die "EMPTY CX STACK" unless @$cxs;
    DEBUG and die "EMPTY OP QUEUE" unless @$opq;
  }
  DEBUG and DEBUG_WARN($cxs, $opq);
  my (undef, $host) = @{pop @$opq};
  return $host;
}

1;
