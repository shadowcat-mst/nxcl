package NXCL::OpUtils;

use NXCL::Exporter;

our @EXPORT
  = our @OPNAMES
  = qw(
      EVAL
      CALL
      CMB9
      CMB6
      ECDR
      CONS
      SNOC
      LIST
      JUST
      DROP
      HOST
      ECTX
      LCTX
      OVER
      DUP2
    );

sub make_op ($type, @args) {
  [ $type => @args ]
}

foreach my $op_type (@EXPORT) {
  eval "sub ${op_type} { make_op ${op_type} => \@_ }; 1"
    or  die "Couldn't eval ${op_type}: $@";
}

push @EXPORT, qw(DOCTX INCTX);

sub DOCTX {
  die unless @_ == 3 or @_ == 4;
  my $thing = shift;
  my $count = shift;
  my @scope = $#_ ? shift : ();
  my @ops = (@{+shift}, LCTX());
  return (ECTX($thing, scalar(@ops) + $count, @scope), @ops);
}

1;
