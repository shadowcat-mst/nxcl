package NXCL::ScopeT;

use NXCL::ReprTypes qw(DictR);
use NXCL::Utils qw(mset object_is raw panic uncons flatten);
use NXCL::TypeFunctions qw(
  make_OpDict OpDict_Inst Val_Inst Var_Inst
  make_String make_List cons_List empty_List
);
use NXCL::TypePackage;

sub make ($store, $intro_as = empty_List) {
 _make DictR ,=> {
    store => $store,
    intro_as => $intro_as,
  };
}

export make => \&make;

method combine => sub ($scope, $cmb, $self, $args) {
  my ($namep) = uncons($args);
  my $name = raw($namep);
  my $store = raw($self)->{store};
  if (object_is $store, OpDict_Inst) {
    my $cell = raw($store)->{$name};
    panic "No value for ${name} in current scope" unless $cell;
    if (mset($cell) == Val_Inst) { # or mset($cell) == Var_Inst) {
      return JUST raw($cell);
    }
    return CMB9 $cell => empty_List;
  }
  return (
    CMB9($store => make_List make_String $name),
    CMB6(empty_List),
  );
};

method assign_via_call => sub ($scope, $cmb, $self, $args) {
  my ($callargs, $vlist) = uncons $args;
  my ($namep) = uncons($callargs);
  my $name = raw($namep);
  my $store = (my $selfd = raw($self))->{store};
  if (object_is $store, OpDict_Inst) {
    if (my $cell = raw($store)->{$name}) {
      # cell() = value
      return CALL(assign_via_call => cons_List($cell, empty_List, $vlist));
    }
    panic "No value for ${name} in current scope"
      unless my $intro_as = $selfd->{intro_as};
    return (
      CALL(new => cons_List($intro_as, $vlist)),
      SNOC(empty_List),
      CONS($namep),
      CONS($self),
      CALL('but_with_entry'),
      RPLS(),
      JUST((uncons $vlist)[0]),
    );
  }
  die "NYI";
};

method but_with_entry => sub ($scope, $cmb, $self, $args) {
  my ($namep, $value) = flatten($args);
  my $store = (my $selfd = raw($self))->{store};
  panic unless object_is($store, OpDict_Inst);
  my $new_store = make_OpDict({ %{raw($store)}, raw($namep) => $value });
  return JUST make($new_store, $selfd->{into_as});
};

method but_intro_as => sub ($scope, $cmb, $self, $args) {
  my ($as) = uncons($args);
  return JUST make(raw($self)->{store}, $as);
};

method but_closed => sub ($scope, $cmb, $self, $args) {
  return JUST make(raw($self)->{store});
};

1;
