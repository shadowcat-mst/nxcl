package NXCL::Exporter;

use strict;
use warnings;
use Import::Into;

sub import {
  strict->import::into(1);
  warnings->import::into(1);
  feature->import::into(1, ':5.16');
  experimental->import::into(1, 'signatures');
  warnings->import::into(1, FATAL => 'uninitialized');
  Exporter->import::into(1, qw(import));
}

1;
