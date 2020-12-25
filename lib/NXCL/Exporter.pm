package NXCL::Exporter;

use strict;
use warnings;
use Import::Into;

sub import {
  NXCL::Package->import::into(1);
  Exporter->import::into(1, qw(import));
}

1;
