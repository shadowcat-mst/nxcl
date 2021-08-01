package NXCL::OpUtils;

use NXCL::Exporter;

our @EXPORT = qw(EVAL CALL CMB9 CMB6 ECDR CONS SNOC JUST DROP HOST);

foreach my $op_type (@EXPORT) {
  eval "sub ${op_type} { [ ${op_type} => \@_ ] }; 1"
    or  die "Couldn't eval ${op_type}: $@";
}

1;
