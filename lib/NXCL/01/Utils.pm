package NXCL::01::Utils;

use NXCL::Exporter;
use Sub::Util qw(set_subname);
use NXCL::01::ReprTypes qw(ConsR);
use NXCL::01::TypeFunctions qw(empty_List);

our @EXPORT_OK = qw(
  panic
  not_combinable
  make_const_combiner
  make_string_combiner
  $NIL
  mkv
  type rtype
  rconsp rnilp rcharsp rnativep rvalp rvarp
  raw uncons flatten
);

# This happens after compile time of 'sub name {' and definition of
# @EXPORT_OK so our import() should still run fine when ListT.pm calls it

require NXCL::01::ListT;
our $NIL = $NXCL::01::ListT::NIL;

sub panic { die $_[0]//'PANIC' }

sub make_const_combiner ($constant) {
  my ($hex) = $constant =~ m/\(0x(\w+)\)/;
  return set_subname 'const_'.$hex =>
    sub ($, $, $, $kstack) {
      return ([ JUST => $constant ], $kstack);
    };
}

sub make_string_combiner ($string) {
  return set_subname 'const_string_'.$string =>
    make_constant_combiner(make_String($string));
}

## raw value utils

sub mkv ($type, $repr, @v) { [ $type => [ $repr => @v ] ] }

sub type ($v) { $v->[0] }
sub rtype ($v) { $v->[1][0] }

sub rconsp ($v) { rtype($v) eq 'cons' }
sub rnilp ($v) { rtype($v) eq 'nil' }
sub rcharsp ($v) { rtype($v) eq 'chars' }
sub rboolp ($v) { rtype($v) eq 'bool' }
sub rnativep ($v) { rtype($v) eq 'native' }
sub rvalp ($v) { rtype($v) eq 'val' }
sub rvarp ($v) { rtype($v) eq 'var' }

sub raw ($v) { $v->[1][1] }

sub uncons ($cons) { @{$cons->[1]}[1,2] }

sub flatten ($cons) {
  my @ret;
  while ($cons->[1][0] == ConsR) {
    my ($car, $cdr) = @{$cons->[1]}[1,2];
    push @ret, $car;
    $cons = $cdr;
  }
  return @ret;
}

1;
