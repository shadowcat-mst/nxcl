package NXCL::ExprUtils;

use NXCL::Utils qw(uncons rnilp panic);
use NXCL::TypeFunctions qw(make_Native);
use NXCL::OpUtils qw(JUST);
use NXCL::Exporter;

our @EXPORT = qw($ESCAPE $IDENTITY);

our $ESCAPE = make_Native \&escape;
our $IDENTITY = make_Native \&identity;

sub escape ($args) {
  my ($arg, $extra) = uncons($args);
  panic "One arg only" unless rnilp($extra);
  return JUST $arg;
}

# This should probably just be wrap($ESCAPE) ?

sub identity ($args) { die }

1;
