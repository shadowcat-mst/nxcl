package NXCL::ApMethT;

use NXCL::Utils qw(uncons raw);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(cons_List make_List empty_List make_String);
use NXCL::TypeSyntax;

export make ($opv) { _make ValR ,=> $opv }

methodn to_xcl_string {
  state $fmt = make_String('ApMeth(%s)');
  return (
    CALL('to_xcl_string' => make_List(raw($self))),
    LIST($fmt),
    CALL('sprintf'),
  );
}

methodx COMBINE {
  my ($inv, $method_args) = uncons($args);
  return (
    EVAL($method_args),
    CONS($inv),
    CMB9(raw($self)),
  );
}

1;
