package NXCL::NativeT;

use NXCL::Utils qw(uncons raw);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(make_String make_Compound make_Name make_List);
use Sub::Util qw(subname);
use NXCL::TypeSyntax;

export make ($sub) { _make NativeR ,=> $sub }

export method ($name) {
  make sub ($args) {
    my ($proto, $method_args) = uncons($args);
    return (
      EVAL($proto),
      SNOC($method_args),
      CALL($name)
    );
  }
}

export just ($sub) {
  make sub ($args) { JUST($sub->($args)) }
}

export name_of ($native) { subname(\&{raw($native)}) }

methodx AS_PLAIN_EXPR {
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
