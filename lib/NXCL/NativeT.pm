package NXCL::NativeT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypePackage;

export make => \&make;

sub make ($sub) { _make NativeR ,=> $sub }

method combine => sub ($scope, $cmb, $self, $args) {
  raw($self)->($scope, $self, $args);
};

1;
