package NXCL::PairT;

use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeSyntax;

export make ($l, $r) { _make ConsR ,=> $l, $r }

1;
