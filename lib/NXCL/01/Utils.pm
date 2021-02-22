package NXCL::01::Utils;

use NXCL::Exporter;
use Carp qw(croak);
use Sub::Util qw(set_subname);
use NXCL::01::ReprTypes qw(ConsR);

our @EXPORT_OK = qw(
  panic
  mkv
  mset rtype
  rconsp rnilp rcharsp rnativep rvalp rvarp
  raw uncons flatten
);

sub panic { croak $_[0]//'PANIC' }

## raw value utils

sub mkv ($mset, $rtype, @v) { [ $mset => [ $rtype => @v ] ] }

sub mset ($v) { $v->[0] }

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
