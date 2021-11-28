package NXCL::CxRefT;

use Scalar::Util qw(weaken);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::Utils qw(uncons flatten raw panic);
use NXCL::TypePackage;

export make => sub ($cx) {
  weaken($cx);
  _make ValR ,=> $cx;
};

method is_active => sub ($self, $) {
  JUST make_Bool defined(raw($self));
};

method return_to => sub ($self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  LCTX $cx, (uncons($args))[0];
};

method get_dynamic_value => sub ($self, $args) {
  my $name = raw((uncons($args))[0]);
  panic "No dynamic value for ${name}"
    unless my $value = raw($self)->[1]{$name};
  return JUST $value;
};

method set_dynamic_value => sub ($self, $args) {
  my ($namep, $value) = flatten($args);
  my $name = raw($namep);
  $_ = { %{$_}, $name => $value } for raw($self)->[1];
  return JUST $value;
};

method scope => sub ($self, $args) {
  return JUST raw($self)->[2];
};

1;
