package NXCL::01::ScopeT;

use NXCL::01::ReprTypes qw(VarR);
use NXCL::01::TypePackage;

export make => sub ($store) { _make VarR ,=> $store };

1;
