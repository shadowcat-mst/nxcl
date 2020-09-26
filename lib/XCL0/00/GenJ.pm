package XCL0::00::GenJ;

use Mojo::Base -strict, -signatures;
use XCL0::00::GenRaw;
use JSON::Dumper::Compact qw(jdc);
use Exporter 'import';

our @EXPORT = (
  @XCL0::00::GenRaw::EXPORT,
  'genj'
);

sub genj ($v) { jdc $v }

1;
