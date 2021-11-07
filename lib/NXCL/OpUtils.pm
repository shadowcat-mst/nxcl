package NXCL::OpUtils;

use NXCL::Exporter;

our @EXPORT
  = our @OPNAMES
  = qw(EVAL CALL CMB9 CMB6 ECDR CONS SNOC JUST DROP HOST ECTX LCTX OVER);

sub make_op ($type, @args) {
  [ $type => @args ]
}

foreach my $op_type (@EXPORT) {
  eval "sub ${op_type} { make_op ${op_type} => \@_ }; 1"
    or  die "Couldn't eval ${op_type}: $@";
}

push @EXPORT, qw(INCTX);

sub INCTX {
  die unless @_ == 2 or @_ == 3;
  my $thing = shift;
  my @scope = $#_ ? shift : ();
  my @ops = (@{+shift}, LCTX());
  return (ECTX($thing, scalar(@ops), @scope), @ops);
}

1;
