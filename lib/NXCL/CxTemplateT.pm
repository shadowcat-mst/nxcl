package NXCL::CxTemplateT;

use Scalar::Util qw(weaken);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypeFunctions qw(
  make_Bool make_List cons_List make_Dict cons_Combine list_Combine
  CxTemplate
);
use NXCL::Utils qw(uncons flatten raw panic);
use NXCL::TypeSyntax;

export make ($scope, $dynamics) {
  _make DictR, => {
    scope => $scope,
    dynamics => $dynamics,
  };
}

staticx new {
  my ($scope, $dynamics) = flatten($args);
  JUST make $scope, $dynamics;
};

methodn is_active {
  JUST make_Bool 0;
}

methodx return {
  panic "Can't return from a CxTemplate";
}

methodx defer {
  panic "Can't register defer callbacks on a CxTemplate";
};

method get_dynamic_value {
  my $name = raw((uncons($args))[0]);
  my $dyn = raw(raw($self)->{dynamics});
  panic "No dynamic value for ${name}"
    unless my $value = $dyn->{$name};
  return JUST $value;
}

method set_dynamic_value {
  my ($namep, $value) = flatten($args);
  my $name = raw($namep);
  my $dyn = raw(raw($self)->{dynamics});
  my $new_dyn = { %{$dyn}, $name => $value };
  raw($self)->{dynamics} = make_Dict($new_dyn);
  return JUST $value;
}

methodn scope {
  return JUST raw($self)->{scope};
};

method eval {
  my ($expr) = uncons($args);
  my ($scope, $dyn_dict) = @{raw($self)}{qw(scope dynamics)};
  return (
    ECTX($expr, raw($dyn_dict), 2, $scope),
    EVAL($expr),
    LCTX(undef),
  );
}

method call {
  Inst_eval($self, make_List(list_Combine($args)));
}

method derive {
  my ($scope, $dyn_dict) = @{raw($self)}{qw(scope dynamics)};
  return (
    CALL(derive => cons_List($scope, $args)),
    SNOC(make_List($dyn_dict)),
    CONS(CxTemplate),
    CALL('new')
  );
}

1;
