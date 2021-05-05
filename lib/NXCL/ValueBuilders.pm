package NXCL::ValueBuilders;

use NXCL::Exporter;
use NXCL::TypeFunctions qw(
  make_Combine
  make_Compound
  make_Name
  make_Int
  make_List
  make_String
);

our @EXPORT = qw(
  Cmb
  Cmp
  N
  I
  L
  S
  Call
);

sub Cmb (@args) { make_Combine(@args) }

sub Cmp (@args) { make_Compound(@args) }

sub N :prototype($) ($v) { make_Name($v) }

sub I :prototype($) ($v) { make_Int($v) }

sub S :prototype($) ($v) { make_String($v) }

sub L (@v) { make_List(@v) }

sub Call ($name, @rest) { Cmb(N"$name", @rest) }

1;
