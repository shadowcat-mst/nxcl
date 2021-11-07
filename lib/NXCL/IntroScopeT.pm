package NXCL::IntroScopeT;

use NXCL::ReprTypes qw(DictR);
use NXCL::Utils qw(panic flatten uncons raw object_is);
use NXCL::TypeFunctions qw(
  cons_List empty_List
  make_OpDict OpDict_Inst
);
use NXCL::TypePackage;

sub make ($scope, $intro_as) {
  _make DictR ,=> {
    scope => $scope,
    intro_as => $intro_as,
  };
}

export make => \&make;

method get_value_for_name => sub ($scope, $cmb, $self, $args) {
  return CALL(get_value_for_name
    => cons_List(raw($self)->{scope}, $args)
  );
};

method set_value_for_name => sub ($scope, $cmb, $self, $args) {
  my ($namep, $vlist) = uncons($args);
  my $intro_as = raw($self)->{intro_as};
  return (
    CALL(new => cons_List($intro_as, $vlist)),
    SNOC(empty_List),
    CONS($namep),
    CONS($self),
    CALL('set_cell_for_name'),
    DROP(),
    JUST((uncons($vlist))[0])
  );
};

method set_cell_for_name => sub ($scope, $cmb, $self, $args) {
  my ($namep, $cell) = flatten($args);
  my $store = raw(my $intscope = raw($self)->{scope});
  panic "NYI" unless object_is($store, OpDict_Inst);
  # this probably *could* mutate the hashref directly but meh
  my $new_store = make_OpDict({ %{raw($store)}, raw($namep) => $cell });
  raw($intscope) = $new_store;
  return JUST $cell;
};

1;
