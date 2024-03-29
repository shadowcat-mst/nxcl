package NXCL::Package;

use strict;
use warnings;
use Import::Into;

sub import {
  strict->import::into(1);
  warnings->import::into(1);
  feature->import::into(1, ':5.16');
  experimental->import::into(1, 'signatures');
  warnings->import::into(1, FATAL => qw(uninitialized redefine));
  warnings->unimport::out_of(1, 'once');
  NXCL::Require->import::into(1);
}

1;
