package NXCL::01::ScopeT;

use NXCL::01::TypeExporter;
use NXCL::01::ReprTypes qw(VarR);

sub make ($store) { _make VarR ,=> $store }

1;
