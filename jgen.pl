use Mojo::Base -strict, -signatures;

use XCL0::00::GenRaw;
use JSON::Dumper::Compact qw(jdc);

sub printj ($thing) {
  print "--\n".jdc($thing)."--\n";
}

printj C(N 'foo', S 'bar', L(S 'a', S 'b'));

1;
