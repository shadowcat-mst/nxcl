package NXCL::NativeT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(make_String);
use Sub::Util qw(subname);
use NXCL::TypeSyntax;

export make ($sub) { _make NativeR ,=> $sub }

methodn to_xcl_string {
  # should indirect via Combine maybe?
  return JUST make_String("Native('".subname(\&{raw($self)})."')");
}

methodx COMBINE {
  raw($self)->($self, $args);
}

1;
