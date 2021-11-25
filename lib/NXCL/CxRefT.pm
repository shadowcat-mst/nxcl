package NXCL::CxRefT;

use Scalar::Util qw(weaken);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::Utils qw(uncons raw panic);
use NXCL::TypePackage;

export make => sub ($cx) {
  weaken($cx);
  _make ValR ,=> $cx;
};

method 'is-active' => sub ($, $self, $) {
  JUST make_Bool defined(raw($self));
};

method 'return-to' => sub ($, $self, $args) {
  panic "Inactive CxRef" unless defined(my $cx = raw($self));
  LCTX $cx, (uncons($args))[0];
};

1;
