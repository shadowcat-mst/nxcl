package XCL0::Exporter;

use Mojo::Base -strict;
use Import::Into;

sub import {
  Mojo::Base->import::into(1, -strict, -signatures);
  warnings->import::into(1, 'uninitialized');
  Exporter->import::into(1, qw(import));
}

1;
