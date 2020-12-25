package NXCL::Class;

use strict;
use warnings;
use Import::Into;

sub import {
  Mu::Tiny->import::into(1);
  NXCL::Package->import::into(1);
}

1;
