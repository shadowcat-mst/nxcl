package NXCL::IntroScopeT;

use NXCL::ReprTypes qw(DictR);
use NXCL::TypeFunctions qw(cons_List);
use NXCL::TypePackage;

sub make ($scope, $intro_as) {
  _make DictR ,=> {
    scope => $scope,
    intro_as => $intro_as,
  };
}

method get_value_for_name => sub ($scope, $cmb, $self, $args) {
  return CALL(get_value_for_name
    => cons_List(raw($self)->{scope}, $args)
  );
};

method set_value_for_name => sub ($scope, $cmb, $self, $args) {
  my ($namep, $value) = flatten($args);
  my $store = raw(my $scope = raw($self)->{scope});
  panic "NYI" unless object_is($store, OpDict_Inst);
  # this probably *could* mutate the hashref directly but meh
  my $new_store = make_OpDict({ %{raw($store)}, raw($namep) => $value });
  raw($scope) = $new_store;
  return JUST $value;
};

1;
