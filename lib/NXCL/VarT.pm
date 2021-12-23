package NXCL::VarT;

use NXCL::Utils qw(rnilp raw panic uncons);
use NXCL::ReprTypes qw(VarR);
use NXCL::TypeSyntax;

export make ($val) { _make VarR ,=> $val }

staticx new {
  return JUST make((uncons $args)[0]);
}

methodn COMBINE {
  return JUST raw($self);
}

methodx ASSIGN_VIA_CALL {
  my ($call_args, $assign) = uncons($args);
  my ($new_value) = uncons($assign);
  raw($self) = $new_value;
  return JUST $new_value;
}

1;
