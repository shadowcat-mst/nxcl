use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Runtime qw(mkv type rtype);

is +(my $v = mkv(X => y => 'z')), [ X => [ y => 'z' ] ];

is type($v), 'X';

is rtype($v), 'y';



done_testing;
