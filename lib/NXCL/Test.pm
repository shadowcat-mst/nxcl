package NXCL::Test;

use Import::Into;

sub import {
  Test2::V0->import::into(1);
  NXCL::Package->import::into(1);
}

1;
