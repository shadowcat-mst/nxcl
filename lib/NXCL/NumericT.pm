package NXCL::NumericT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::TypeSyntax;

export make ($string) { _make CharsR, => $string }

methodn to_xcl_string {
  # this is wrong
  return JUST make("N'".raw($self)."'");
}

1;
