package NXCL::TypeMaker;

use NXCL::TypeFunctions ();
use NXCL::Exporter;

our @EXPORT = qw(make_value);

sub make_value ($type, @v) {
  my $maker = "make_${type}";
  NXCL::TypeFunctions->import($maker);
  __PACKAGE__->can($maker)->(@v);
}

1;
