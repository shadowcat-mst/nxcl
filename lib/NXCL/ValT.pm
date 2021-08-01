package NXCL::ValT;

use NXCL::Utils qw(rnilp raw panic);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

export make => sub ($val) { _make ValR ,=> $val };

method combine => sub ($scope, $cmb, $self, $args) {
  panic unless rnilp $args;
  return JUST raw($self);
};

1;
