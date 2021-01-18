package NXCL::01::Utils;

use NXCL::Exporter;
use Sub::Util qw(set_subname);
use NXCL::01::TypeFunctions qw(empty_List);

our @EXPORT_OK = qw(
  panic
  not_combinable
  evaluate_to_value
  make_const_combiner
  make_string_combiner
  $NIL
  mkv
  type rtype
  rconsp rnilp rcharsp rnativep rvalp rvarp
  raw uncons flatten
);

our $NIL;

sub panic { die $_[0]//'PANIC' }

sub not_combinable {
  die "Not combinable";
}

sub evaluate_to_value ($, $value, $, $kstack) {
  my ($kar, $kdr) = uncons($kstack);
  return (
    [ @$kar, $value ],
    $kdr
  );
}

sub make_const_combiner ($constant) {
  my ($hex) = $constant =~ m/\(0x(\w+)\)/;
  return set_subname 'const_'.$hex =>
    sub ($scope, $combiner, $args, $kstack) {
      return evaluate_to_value($scope, $constant, $NIL, $kstack);
    };
}

sub make_string_combiner ($string) {
  return set_subname 'const_string_'.$string =>
    make_constant_combiner(make_String($string));
}

$NIL = empty_List();

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
  while ($cons->[1][0] eq 'cons') {
    my ($car, $cdr) = @{$cons->[1]}[1,2];
    push @ret, $car;
    $cons = $cdr;
  }
  return @ret;
}

1;
