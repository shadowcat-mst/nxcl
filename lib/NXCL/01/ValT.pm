package NXCL::01::ValT;

use NXCL::01::Utils qw(rnilp raw panic);
use NXCL::01::ReprTypes qw(ValR);
use NXCL::01::TypeExporter;

export make => sub ($val) { _make ValR ,=> $val };

method combine => sub ($scope, $cmb, $self, $args, $kstack) {
  panic unless rnilp $args;
  return ([ JUST => raw($self) ], $kstack);
};

1;
