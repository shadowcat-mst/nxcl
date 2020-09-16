package XCL0::00::Writer;

use XCL0::00::Runtime qw(typ type raw flatten);
use Mojo::Base -strict, -signatures;
use Exporter 'import';

our @EXPORT_OK = qw(write_string);

sub write_string ($v) {
  my $type = type $v;
  return raw($v) if $type eq 'Name';
  return q{'}.raw($v).q{'} if $type eq 'String';
  if ($type eq 'Call') {
    return join ' ', '[', (map write_string($_), flatten($v)), ']';
  }
  die;
}

1;
