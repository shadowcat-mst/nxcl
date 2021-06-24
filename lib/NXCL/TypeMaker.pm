package NXCL::TypeMaker;

use NXCL::TypeFunctions ();
use NXCL::Exporter;

our @EXPORT = qw(make_value);

sub make_value ($type, @v) {
  my $maker_name = "make_${type}";
  my $maker = __PACKAGE__->can($maker_name) || do {
    NXCL::TypeFunctions->import($maker_name);
    __PACKAGE__->can($maker_name);
  };
  $maker->(@v);
}

1;
