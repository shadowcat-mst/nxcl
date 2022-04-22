package NXCL::NumericT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::TypeSyntax;

export make ($string) { _make CharsR, => $string }

method AS_PLAIN_EXPR { JUST $self }

1;
