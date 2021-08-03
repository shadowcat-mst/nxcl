package NXCL::ScopeT;

use NXCL::ReprTypes qw(DictR);
use NXCL::Utils qw(mset object_is raw panic uncons);
use NXCL::TypeFunctions qw(
  OpDict_Inst Val_Inst Var_Inst
  make_String make_List empty_List
);
use NXCL::TypePackage;

export make => sub ($store) { _make DictR ,=> { store => $store } };

method combine => sub ($scope, $cmb, $self, $args) {
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

1;
