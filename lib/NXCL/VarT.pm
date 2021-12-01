package NXCL::VarT;

use NXCL::Utils qw(rnilp raw panic uncons);
use NXCL::ReprTypes qw(VarR);
use NXCL::TypePackage;

sub make ($val) { _make VarR ,=> $val };

export make => \&make;

static new => sub ($self, $args) {
  return JUST make((uncons $args)[0]);
};

method COMBINE => sub ($self, $args) {
  panic unless rnilp $args;
  return JUST raw($self);
};

method assign_via_call => sub ($self, $args) {
  my ($call_args, $assign) = uncons($args);
  my ($new_value) = uncons($assign);
  raw($self) = $new_value;
  return JUST $new_value;
};

1;
