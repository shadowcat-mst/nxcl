use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Runtime qw(
  mkv type rtype raw car cdr list uncons flatten
);

is +(my $v = mkv(X => y => 'z')), [ X => [ y => 'z' ] ];

is type($v), 'X';

is rtype($v), 'y';

is raw($v), 'z';

my $list = list map mkv(String => string => $_), qw(a b c);

is raw(car($list)), 'a';

is raw(car(cdr $list)), 'b';

is raw(car($list, 1)), 'b';

is raw(car(cdr($list, 2))), 'c';

{
  my ($x, $y) = uncons($list);
  is raw($x), 'a';
  is raw(car $y), 'b';
}

is [ map raw($_), flatten($list) ], [ qw(a b c) ];

done_testing;
