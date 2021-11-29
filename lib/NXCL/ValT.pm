package NXCL::ValT;

use NXCL::Utils qw(rnilp raw panic uncons);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

sub make ($val) { _make ValR ,=> $val };

export make => \&make;

static new => sub ($self, $args) {
  return JUST make((uncons $args)[0]);
};

method combine => sub ($self, $args) {
  panic unless rnilp $args;
  return JUST raw($self);
};

1;
