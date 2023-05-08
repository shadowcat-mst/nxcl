package NXCL::KVPairT;

use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeSyntax;

export make ($k, $v) { _make ConsR ,=> $k, $v }

1;
