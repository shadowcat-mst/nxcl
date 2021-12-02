package NXCL::CxRefT;

use Scalar::Util qw(weaken);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(
  make_Bool make_List make_OpDict list_Combine
  CxTemplate
);
use NXCL::Utils qw(uncons flatten raw panic);
use NXCL::TypePackage;

export make => sub ($cx) {
  weaken($cx);
  _make NativeR ,=> $cx;
};

method is_active => sub ($self, $) {
  JUST make_Bool defined(raw($self));
};

wrap method return_to => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  LCTX $cx, (uncons($args))[0];
};

wrap method on_leave => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my ($cb) = uncons($args);
  unshift @{$cx->[4]}, $cb;
  JUST $self;
};

wrap method get_dynamic_value => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my $name = raw((uncons($args))[0]);
  panic "No dynamic value for ${name}"
    unless my $value = raw($self)->[1]{$name};
  return JUST $value;
};

wrap method set_dynamic_value => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my ($namep, $value) = flatten($args);
  my $name = raw($namep);
  $_ = { %{$_}, $name => $value } for raw($self)->[1];
  return JUST $value;
};

method scope => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return JUST raw($self)->[2];
};

wrap method eval => my $eval = sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  my ($expr) = uncons($args);
  return (
    ECTX($expr, $cx->[1], 2, $cx->[2]),
    EVAL($expr),
    LCTX(undef),
  );
};

wrap method call => sub ($self, $args) {
  $eval->($self, make_List(list_Combine($args)));
};

method derive => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  return (
    CALL(derive => make_List($cx->[2])),
    SNOC(make_List(make_OpDict $cx->[1])),
    CONS(CxTemplate),
    CALL('new'),
  );
};

1;
