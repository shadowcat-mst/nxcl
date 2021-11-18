package NXCL::NumericT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::TypePackage;

export make => \&make;

sub make ($string) { _make CharsR, => $string }

method to_xcl_string => sub ($scope, $self, $) {
  # this is wrong
  return JUST make("N'".raw($self)."'");
};

1;
