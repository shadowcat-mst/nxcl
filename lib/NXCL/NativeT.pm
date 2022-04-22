package NXCL::NativeT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(make_String make_Compound make_Name make_List);
use Sub::Util qw(subname);
use NXCL::TypeSyntax;

export make ($sub) { _make NativeR ,=> $sub }

methodn AS_PLAIN_EXPR {
  return JUST make_Compound(
    make_Name('Native'),
    make_Name('.'),
    make_Name('FROM'),
    make_List(make_String(subname(\&{raw($self)}))),
  );
}

methodx COMBINE {
  raw($self)->($self, $args);
}

1;
