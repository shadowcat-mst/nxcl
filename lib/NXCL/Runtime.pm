package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(object_is uncons raw rnilp);
use NXCL::MethodUtils;
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(Native_Inst make_List cons_List);
use if !__PACKAGE__->can('DEBUG'), constant => DEBUG => 0;

our @EXPORT_OK = qw(run_til_host);

sub take_step_EVAL ($cxs, $ops, $value) {
  my $scope = $cxs->[-1][1];
  push @$ops, reverse
    call_method($scope, evaluate => make_List($value));
}

sub take_step_CALL ($cxs, $ops, $methodp, $args) {
  my $scope = $cxs->[-1][1];
  push @$ops, reverse
    call_method($scope, $methodp, $args);
}

sub take_step_CMB9 ($cxs, $ops, $cmb, $args) {
  my $scope = $cxs->[-1][1];
  push @$ops, reverse(
    object_is($cmb, Native_Inst)
      ? raw($cmb)->($scope, $args)
      : call_method($scope, combine => cons_List($cmb, $args))
  );
}

sub take_step_CMB6 ($cxs, $ops, $args, $cmb) {
  take_step_CMB9($cxs, $ops, $cmb, $args);
}

sub take_step_ECDR ($cxs, $ops, $cdr, $car) {
  push @$ops, reverse(
    rnilp($cdr)
      ? JUST(make_List($car))
      : (EVAL($cdr), CONS($car))
  );
}

sub take_step_JUST ($cxs, $ops, $val) {
  push @{$ops->[-1]}, $val;
}

sub take_step_CONS ($cxs, $ops, @cons) {
  push @{$ops->[-1]}, cons_List(@cons);
}

sub take_step_SNOC ($cxs, $ops, $cdr, $car) {
  push @{$ops->[-1]}, cons_List($car, $cdr);
}

sub take_step_LIST ($cxs, $ops, @list) {
  push @{$ops->[-1]}, make_List(@list);
}

sub take_step_DROP { }

sub take_step_OVER ($cxs, $ops, $count, $val) {
  splice @$ops, -$count, 0, JUST($val);
}

sub take_step_DUP2 ($cxs, $ops, $count, $val) {
  splice @$ops, -$count, 0, JUST($val);
  push @$ops, JUST($val);
}

sub take_step_ECTX ($cxs, $ops, $thing, $count, $scope) {
  push @$cxs, [
     cons_List($thing, $cxs->[-1][0]),
     $scope,
     scalar(@$ops) - $count,
  ];
}

sub take_step_LCTX ($cxs, $ops, $val) {
  pop @$cxs;
  push @{$ops->[-1]}, $val;
}

our %step_func = map +($_ => __PACKAGE__->can("take_step_${_}")),
  @NXCL::OpUtils::OPNAMES;

sub take_step ($cxs, $ops) {
  DEBUG and DEBUG_WARN($cxs, $ops);
  my ($op, @v) = @{pop @$ops};
  die "Unkown op type $op" unless my $step_func = $step_func{$op};
  $step_func->($cxs, $ops, @v);
  return;
}

sub run_til_host ($cxs, $ops) {
  while ($ops->[-1][0] ne 'HOST') {
    take_step($cxs, $ops);
    DEBUG and die "EMPTY CX STACK" unless @$cxs;
    DEBUG and die "EMPTY OP STACK" unless @$ops;
  }
  DEBUG and DEBUG_WARN($cxs, $ops);
  my (undef, $host) = @{pop @$ops};
  return $host;
}

1;
