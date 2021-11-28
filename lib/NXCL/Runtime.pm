package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(object_is uncons raw rnilp panic);
use NXCL::MethodUtils;
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(Native_Inst make_List cons_List make_CxRef);
use if !__PACKAGE__->can('DEBUG'), constant => DEBUG => 0;

our @EXPORT_OK = qw(run_til_host);

sub take_step_EVAL ($cxs, $ops, $value) {
  my $scope = $cxs->[-1][2];
  push @$ops, reverse
    call_method($scope, evaluate => make_List($value));
}

sub take_step_CALL ($cxs, $ops, $methodp, $args) {
  my $scope = $cxs->[-1][2];
  push @$ops, reverse
    call_method($scope, $methodp, $args);
}

sub take_step_CMB9 ($cxs, $ops, $cmb, $args) {
  my $scope = $cxs->[-1][2];
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

sub take_step_OVER ($cxs, $ops, $count, $type, $val) {
  splice @$ops, -$count, 0, [ $type => $val ];
}

sub take_step_DUP2 ($cxs, $ops, $count, $type, $val) {
  splice @$ops, -$count, 0, [ $type => $val ];
  push @$ops, JUST($val);
}

sub take_step_ECTX ($cxs, $ops, $thing, $dynv, $count, $scope) {
  my ($top_thing, $top_dynv, $top_scope) = @{$cxs->[-1]};
  push @$cxs, [
     cons_List($thing, $top_thing),
     ($dynv // $top_dynv),
     ($scope // $top_scope),
     scalar(@$ops) - $count,
  ];
}

sub take_step_LCTX ($cxs, $ops, $cx, $val) {
  my $lctx_idx;
  if ($cx) {
    FIND: foreach my $cand (1..$#$cxs) {
      if ($cxs->[-$cand] == $cx) {
        $lctx_idx = -$cand;
        last FIND;
      }
    }
    panic "Attempt to leave invalid cx" unless $lctx_idx;
  } else {
    $lctx_idx = -1;
  }
  my @left = splice @$cxs, $lctx_idx;
  $#$ops = $left[0][-1] - 1;
  push @{$ops->[-1]}, $val;
}

sub take_step_GCTX ($cxs, $ops) {
  push @{$ops->[-1]}, make_CxRef($cxs->[-1]);
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
