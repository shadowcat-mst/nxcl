package NXCL::PairT;

use NXCL::ReprTypes qw(ConsR);
use NXCL::TypePackage;

export make => sub ($l, $r) { _make ConsR ,=> $l, $r };

1;
