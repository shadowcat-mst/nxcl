package NXCL::01::ValT;

use NXCL::01::Utils qw(rnilp raw panic);
use NXCL::01::ReprTypes qw(ValR);
use NXCL::01::TypePackage;

export make => sub ($val) { _make ValR ,=> $val };

method combine => sub ($scope, $cmb, $self, $args) {
  panic unless rnilp $args;
  return ([ JUST => raw($self) ]);
};

1;
