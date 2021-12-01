package NXCL::NativeT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(NativeR);
use NXCL::TypeFunctions qw(make_String);
use Sub::Util qw(subname);
use NXCL::TypePackage;

export make => \&make;

sub make ($sub) { _make NativeR ,=> $sub }

method to_xcl_string => sub ($self, $) {
  # should indirect via Combine maybe?
  return JUST make_String("Native('".subname(\&{raw($self)})."')");
};

method COMBINE => sub ($self, $args) {
  raw($self)->($self, $args);
};

1;
