package NXCL::Utils;

use NXCL::Exporter;
use Carp qw(croak);
use Sub::Util qw(set_subname);
use NXCL::ReprTypes;

our @EXPORT_OK = qw(
  panic
  mkv
  mset rtype
  rboolp rcharsp rbytesp rnilp rintp rvalp rvarp rconsp rdictp rnativep
  raw uncons flatten
);

sub panic { croak $_[0]//'PANIC' }

## raw value utils

sub mkv ($mset, $rtype, @v) { [ $mset => [ $rtype => @v ] ] }

sub mset ($v) { $v->[0] }

sub rtype ($v) { $v->[1][0] }

sub rboolp ($v) { rtype($v) eq BoolR }
sub rcharsp ($v) { rtype($v) eq CharsR }
sub rbytesp ($v) { rtype($v) eq BytesR }
sub rnilp ($v) { rtype($v) eq NilR }
sub rintp ($v) { rtype($v) eq IntR }
sub rvalp ($v) { rtype($v) eq ValR }
sub rvarp ($v) { rtype($v) eq VarR }
sub rconsp ($v) { rtype($v) eq ConsR }
sub rdictp ($v) { rtype($v) eq DictR }
sub rnativep ($v) { rtype($v) eq NativeR }

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
