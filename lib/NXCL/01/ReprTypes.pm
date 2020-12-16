package NXCL::01::ReprTypes;

use NXCL::Exporter;

use constant our $CONST_SPEC = {
  map +(ucfirst("${_}R") => $_),
    qw(bool chars bytes nil int val var cons dict native)
};

our @EXPORT = sort keys %{our $CONST_SPEC};

1;
