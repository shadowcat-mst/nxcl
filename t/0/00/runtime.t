use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::GenRaw;
use XCL0::00::Runtime qw(mkv type rtype raw car cdr);

is +(my $v = mkv(X => y => 'z')), [ X => [ y => 'z' ] ];

is type($v), 'X';

is rtype($v), 'y';

is raw($v), 'z';

my $list = L(map mkv(String => string => $_), qw(a b c));

is raw(car($list)), 'a';

is raw(car(cdr $list)), 'b';

is raw(car($list, 1)), 'b';

is raw(car(cdr($list, 2))), 'c';

done_testing;
