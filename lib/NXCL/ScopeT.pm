package NXCL::ScopeT;

use NXCL::ReprTypes qw(VarR);
use NXCL::TypePackage;

export make => sub ($store) { _make VarR ,=> $store };

1;
