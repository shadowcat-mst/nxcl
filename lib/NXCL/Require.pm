package NXCL::Require;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw(load_module load_and_call_cb);

sub load_module {
  my $pkg = shift;
  require join('/', split '::', $pkg).'.pm';
  $pkg;
}

sub load_and_call_cb {
  my ($pkg, $call, @args) = @_;
  sub { load_module($pkg)->$call(@args) };
}

1;
