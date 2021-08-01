package NXCL::NumericT;

use NXCL::Utils qw(panic flatten raw mset);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::TypePackage;

export make => \&make;

sub make ($string) { _make CharsR, => $string }

method to_xcl_string => sub ($scope, $cmb, $self, $) {
  # this is wrong
  return JUST make("N'".raw($self)."'");
};

1;
