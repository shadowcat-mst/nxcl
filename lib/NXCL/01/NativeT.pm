package NXCL::01::NativeT;

use NXCL::01::Utils qw(raw);
use NXCL::01::ReprTypes qw(NativeR);
use NXCL::01::TypeExporter;

sub make ($sub) { _make NativeR ,=> $sub }

method combine => sub ($scope, $cmb, $self, $args) {
  raw($self)->($scope, $self, $args);
};

1;
