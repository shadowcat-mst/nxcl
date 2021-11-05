package NXCL::Utils;

use NXCL::Exporter;
use Sub::Util qw(set_subname);
use NXCL::ReprTypes;

our @EXPORT_OK = qw(
  panic
  mkv
  mset rtype object_is
  rboolp rcharsp rbytesp rnilp rintp rvalp rvarp rconsp rdictp rnativep
  raw uncons flatten
);

sub panic {
  my $err = $_[0]//'PANIC';
  my ($package, $filename, $line) = caller;
  die "${err} (${package} ${filename} ${line})\n";
}

## raw value utils

#sub mkv ($mset, $rtype, @v) { [ $mset => [ $rtype => @v ] ] }

sub mkv ($mset, $rtype, @v) {
  if (1) { # should check a flag later
    panic "mkv called with undefined mset" unless defined($mset);
    panic "mkv called with undefined rtype" unless defined($rtype);
    if (my @undef = grep !defined($v[$_]), 0..$#v) {
      my $failed = (
        @undef == 1
          ? 'argument '.($undef[0]+1)
          : 'arguments '.(join(', ', map $_+1, @undef))
      );
      panic "mkv called with undefined ${failed} of ".scalar(@v);
    }
  }
  return bless([ $mset => [ $rtype => @v ] ], 'NXCL::_::V');
}

sub mset ($v) { $v->[0] }
sub object_is ($v, $mset) { $v->[0] == $mset }

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

sub raw :lvalue ($v) { $v->[1][1] }

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
