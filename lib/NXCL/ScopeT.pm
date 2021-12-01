package NXCL::ScopeT;

use NXCL::ReprTypes qw(DictR);
use NXCL::Utils qw(mset object_is raw panic uncons flatten rnilp);
use NXCL::TypeFunctions qw(
  make_OpDict OpDict_Inst Val_Inst Var_Inst
  make_String make_List cons_List empty_List
  make_IntroScope
);
use NXCL::TypePackage;

sub make ($store) {
  _make DictR ,=> {
    store => $store,
  };
}

export make => \&make;

method get_value_for_name => sub ($self, $args) {
  my ($namep) = uncons($args);
  my $name = raw($namep);
  my $store = raw($self)->{store};
  if (object_is $store, OpDict_Inst) {
    my $cell = raw($store)->{$name};
    panic "No value for ${name} in current scope" unless $cell;
    if (mset($cell) == Val_Inst or mset($cell) == Var_Inst) {
      return JUST raw($cell);
    }
    return CMB9 $cell => empty_List;
  }
  return (
    CMB9($store => make_List make_String $name),
    CMB6(empty_List),
  );
};

method set_value_for_name => sub ($self, $args) {
  my ($callargs, $vlist) = uncons $args;
  my ($namep) = uncons($callargs);
  # I am not convinced this conditional is a good idea
  my $name = ref($namep) ? raw($namep) : $namep;
  my $store = raw($self)->{store};
  if (object_is $store, OpDict_Inst) {
    if (my $cell = raw($store)->{$name}) {
      # cell() = value
      return CALL(assign_via_call => cons_List($cell, empty_List, $vlist));
    }
    panic "No value for ${name} in current scope";
  }
  panic "NYI";
};

method set_cell_for_name => sub ($self, $args) {
  my ($namep, $cell) = flatten($args);
  my $store = raw($self)->{store};
  panic "NYI" unless object_is($store, OpDict_Inst);
  # this probably *could* mutate the hashref directly but meh
  my $new_store = make_OpDict({ %{raw($store)}, raw($namep) => $cell });
  raw($self)->{store} = $new_store;
  return JUST $cell;
};

method derive => sub ($self, $args) {
  panic "NYI" unless rnilp $args; # should accept extra value pairs
  return JUST make raw($self)->{store};
};

method introscope => sub ($self, $args) {
  my ($type) = uncons($args);
  return JUST make_IntroScope($self, $type);
};

# COMBINE() should do eval-in-scope
# assign_via_call() should pass through to eval-in-scope where possible

1;
