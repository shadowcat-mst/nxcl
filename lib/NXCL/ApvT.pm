package NXCL::ApvT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export make ($opv) { _make ValR ,=> $opv }

methodx COMBINE {
  return (
    EVAL($args),
    CMB9(raw($self)),
  );
}

1;
