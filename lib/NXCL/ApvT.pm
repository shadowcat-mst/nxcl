package NXCL::ApvT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

export make => sub ($opv) { _make ValR ,=> $opv };

method combine => sub ($scope, $self, $args) {
  return (
    EVAL($args),
    CMB9(raw($self)),
  );
};

1;
