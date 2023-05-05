package NXCL::NativeT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(make_String make_Compound make_Name make_List);
use Sub::Util qw(subname);
use NXCL::TypeSyntax;

export make ($sub) { _make NativeR ,=> $sub }

export method ($name) {
  make sub ($args) { CALL($name => $args) }
}

export just ($sub) {
  make sub ($args) { JUST($sub->($args)) }
}

export name_of ($native) { subname(\&{raw($native)}) }

methodn AS_PLAIN_EXPR {
  return JUST make_Compound(
    make_Name('Native'),
    make_Name('.'),
    make_Name('FROM'),
    make_List(make_String name_of $self),
  );
}

methodx COMBINE {
  # this is arguably correct but everything else is handling just ($args)
  raw($self)->($self, $args);
}

1;
