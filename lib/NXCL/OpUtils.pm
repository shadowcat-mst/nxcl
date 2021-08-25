package NXCL::OpUtils;

use NXCL::Exporter;

our @EXPORT
  = our @OPNAMES
  = qw(EVAL CALL CMB9 CMB6 ECDR CONS SNOC JUST DROP HOST RPLS OVER);

sub make_op ($type, @args) {
  [ $type => @args ]
}

foreach my $op_type (@EXPORT) {
  eval "sub ${op_type} { make_op ${op_type} => \@_ }; 1"
    or  die "Couldn't eval ${op_type}: $@";
}

1;
