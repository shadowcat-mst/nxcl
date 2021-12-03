package NXCL::OpUtils;

use NXCL::TypeFunctions qw(make_Name make_String);
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
      GCTX
      GETN
      SETN
      SETL
      DUPL
      GETL
      USEL
    );

sub make_op ($type, @args) {
  [ $type => @args ]
}

foreach my $op_type (@EXPORT) {
  eval "sub ${op_type} { make_op ${op_type} => \@_ }; 1"
    or  die "Couldn't eval ${op_type}: $@";
}

push @EXPORT, qw(DOCTX DYNREG);

sub DOCTX {
  die unless @_ == 2 or @_ == 3;
  my $thing = shift;
  my @scope = $#_ ? shift : ();
  my @ops = (@{+shift}, LCTX(undef));
  return (ECTX($thing, undef, scalar(@ops), @scope), @ops);
}

sub DYNREG ($name) {
  state $DOT_F = do {
    require NXCL::MethodUtils;
    $NXCL::MethodUtils::DOT_F;
  };
  return (
    GCTX(),
    DUPL('cx'),
    LIST(make_Name($name)),
    CMB9($DOT_F),
    LIST(make_String($name)),
    USEL('cx', 'CONS'),
    CALL('set_dynamic_value'),
    DROP(),
  );
}

1;
