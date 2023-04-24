package NXCL::Runtime;

use NXCL::Exporter;
use NXCL::Utils qw(object_is uncons raw rnilp panic);
use NXCL::MethodUtils;
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(
  Native_Inst make_List cons_List empty_List make_CxRef
);

our @EXPORT_OK = qw(%STEP_FUNC);

sub retops ($ops, @ret) { push @$ops, reverse @ret }
sub retval ($ops, $val) { push @{$ops->[-1]}, $val }

sub take_step_EVAL ($cxs, $ops, $value) {
  retops $ops, call_method(EVALUATE => make_List($value));
}

sub take_step_CALL ($cxs, $ops, $methodp, $args) {
  retops $ops, call_method($methodp, $args);
}

sub take_step_CMB9 ($cxs, $ops, $cmb, $args) {
  retops $ops, (
    object_is($cmb, Native_Inst)
      ? raw($cmb)->($args)
      : call_method(COMBINE => cons_List($cmb, $args))
  );
}

sub take_step_CMB6 ($cxs, $ops, $args, $cmb) {
  take_step_CMB9($cxs, $ops, $cmb, $args);
}

sub take_step_ECDR ($cxs, $ops, $cdr, $car) {
  retops $ops, (
    rnilp($cdr)
      ? JUST(make_List($car))
      : (EVAL($cdr), CONS($car))
  );
}

sub take_step_JUST ($cxs, $ops, $val) {
  retval $ops, $val;
}

sub take_step_CONS ($cxs, $ops, $car, $cdr) {
  retval $ops, cons_List($car, $cdr);
}

sub take_step_SNOC ($cxs, $ops, $cdr, $car) {
  retval $ops, cons_List($car, $cdr);
}

sub take_step_LIST ($cxs, $ops, @list) {
  retval $ops, make_List(@list);
}

sub take_step_DROP { }

sub take_step_ECTX ($cxs, $ops, $thing, $dynv, $count, $scope) {
  my ($top_thing, $top_dynv, $top_scope) = @{$cxs->[-1]};
  push @$cxs, [
     cons_List($thing, $top_thing),
     ($dynv // $top_dynv),
     ($scope // $top_scope),
     scalar(@$ops) - $count,
     [],
     { %{$cxs->[-1][5]} },
  ];
}

sub take_step_LCTX ($cxs, $ops, $cx, $val) {
  $#$ops = $cxs->[-1][3] - 1;
  if (my @leave_cb = @{$cxs->[-1][4]}) {
    $cxs->[-1][4] = [];
    return retops $ops, (
      (map +(CMB9($_, empty_List), DROP()), @leave_cb),
      LCTX($cx, $val),
    );
  }
  my $left = pop @$cxs;
  if ($cx and $cx != $left) {
    retops $ops, LCTX($cx, $val);
  } else {
    retval $ops, $val;
  }
}

sub take_step_GCTX ($cxs, $ops) {
  retval $ops, $cxs->[-1][6] ||= make_CxRef($cxs->[-1]);
}

sub take_step_GETN ($cxs, $ops, $name) {
  my $scope = $cxs->[-1][2];
  retops $ops, call_method(get_value_for_name => make_List($scope, $name));
}

sub take_step_SETN ($cxs, $ops, $name, $value) {
  my $scope = $cxs->[-1][2];
  retops $ops,
    call_method(set_value_for_name => make_List($scope, $name, $value));
}

sub take_step_SETL ($cxs, $ops, $name, $value) {
  $cxs->[-1][5]{$name} = $value;
}

sub take_step_DUPL ($cxs, $ops, $name, $value) {
  $cxs->[-1][5]{$name} = $value;
  retval $ops, $value;
}

sub take_step_USEL ($cxs, $ops, $name, $type, @rest) {
  retops $ops, [ $type => delete($cxs->[-1][5]{$name}), @rest ];
}

sub take_step_GETL ($cxs, $ops, $name, $type, @rest) {
  retval $ops, [ $type => $cxs->[-1][5]{$name}, @rest ];
}

our %STEP_FUNC = map +($_ => __PACKAGE__->can("take_step_${_}")),
  @NXCL::OpUtils::OPNAMES;

1;
