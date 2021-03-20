package NXCL::01::ValueBuilders;

use NXCL::Exporter;
use NXCL::01::TypeFunctions qw(
  make_Combine
  make_Name
  make_Int
  make_List
);

our @EXPORT = qw(
  Cmb
  N
  I
);

sub Cmb ($c, @args) { make_Combine($c, make_List(@args)) }

sub N :prototype($) ($v) { make_Name($v) }

sub I :prototype($) ($v) { make_Int($v) }

1;
