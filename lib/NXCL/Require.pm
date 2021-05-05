package NXCL::Require;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw(nxcl_require nxcl_require_and_call);

sub nxcl_require {
  my $pkg = shift;
  require join('/', split '::', $pkg).'.pm';
  $pkg;
}

sub nxcl_require_and_call {
  my ($pkg, $call, @args) = @_;
  sub { nxcl_require($pkg)->$call(@args) };
}

1;
