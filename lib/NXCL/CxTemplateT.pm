package NXCL::CxTemplateT;

use Scalar::Util qw(weaken);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypeFunctions qw(
  make_Bool make_List make_OpDict
  CxTemplate
);
use NXCL::Utils qw(uncons flatten raw panic);
use NXCL::TypePackage;

sub make ($scope, $dynamics) {
  _make DictR, => {
    scope => $scope,
    dynamics => $dynamics,
  };
};

export make => \&make;

static new => sub ($self, $args) {
  my ($scope, $dynamics) = flatten($args);
  JUST make $scope, $dynamics;
};

method is_active => sub ($self, $) {
  JUST make_Bool 0;
};

method return_to => sub ($self, $args) {
  panic "Can't return from a CxTemplate";
};

method get_dynamic_value => sub ($self, $args) {
  my $name = raw((uncons($args))[0]);
  my $dyn = raw(raw($self)->{dynamics});
  panic "No dynamic value for ${name}"
    unless my $value = $dyn->{$name};
  return JUST $value;
};

method set_dynamic_value => sub ($self, $args) {
  my ($namep, $value) = flatten($args);
  my $name = raw($namep);
  my $dyn = raw(raw($self)->{dynamics});
  my $new_dyn = { %{$dyn}, $name => $value };
  raw($self)->{dynamics} = make_OpDict($new_dyn);
  return JUST $value;
};

method scope => sub ($self, $args) {
  return JUST raw($self)->{scope};
};

wrap method eval => sub ($self, $args) {
  my ($expr) = uncons($args);
  my ($scope, $dyn_dict) = @{raw($self)}{qw(scope dynamics)};
  return (
    ECTX($expr, raw($dyn_dict), 2, $scope),
    EVAL($expr),
    LCTX(undef),
  );
};

method derive => sub ($self, $args) {
  my ($scope, $dyn_dict) = @{raw($self)}{qw(scope dynamics)};
  return (
    CALL(derive => make_List($scope)),
    SNOC(make_List($dyn_dict)),
    CONS(CxTemplate),
    CALL('new')
  );
};

1;
