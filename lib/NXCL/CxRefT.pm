package NXCL::CxRefT;

use Scalar::Util qw(weaken);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(
  make_Bool make_List cons_List make_Dict cons_Combine
  CxTemplate
);
use NXCL::Utils qw(uncons flatten raw panic);
use NXCL::TypeSyntax;

export make ($cx) {
  weaken($cx);
  _make NativeR ,=> $cx;
}

methodn is_active {
  JUST make_Bool defined(raw($self));
}

methodn expr_stack {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return JUST $cx->[0];
}

methodn dynamic_values {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return JUST make_Dict({ %{$cx->[1]} });
}

methodn scope {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return JUST $cx->[2];
}

# 3 -> opdepth, 5 -> locals, 6 -> cache of this CxRef

methodn deferred_thunks {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return JUST make_List(@{$cx->[4]});
}

method return {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return LCTX $cx, (uncons($args))[0];
}

method defer {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my ($cb) = uncons($args);
  unshift @{$cx->[4]}, $cb;
  JUST $self;
}

method get_dynamic_value {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my $name = raw((uncons($args))[0]);
  panic "No dynamic value for ${name}"
    unless my $value = $cx->[1]{$name};
  return JUST $value;
}

method set_dynamic_value {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my ($namep, $value) = flatten($args);
  my $name = raw($namep);
  $_ = { %{$_}, $name => $value } for $cx->[1];
  return JUST $value;
}

method eval {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my ($expr) = uncons($args);
  return (
    ECTX($expr, $cx->[1], 2, $cx->[2]),
    EVAL($expr),
    LCTX(undef),
  );
}

method call {
  CALL(eval => make_List($self, cons_Combine(uncons($args))));
}

method derive {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return (
    CALL(derive => cons_List($cx->[2], $args)),
    SNOC(make_List(make_Dict $cx->[1])),
    CONS(CxTemplate),
    CALL('new'),
  );
}

1;
