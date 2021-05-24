package NXCL::ExprUtils;

use NXCL::Utils qw(uncons rnilp panic);
use NXCL::TypeFunctions qw(make_Native);
use NXCL::Exporter;

our @EXPORT = qw($ESCAPE $IDENTITY);

our $ESCAPE = make_Native \&escape;
our $IDENTITY = make_Native \&identity;

sub escape ($scope, $cmb, $args, $kstack) {
  my ($arg, $extra) = uncons($args);
  panic "One arg only" unless rnilp($extra);
  return ([ JUST => $arg ], $kstack);
}

sub identity { die }

1;
