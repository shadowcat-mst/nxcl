use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Runtime qw(
  mkv type rtype raw car cdr list uncons flatten deref
  make_scope combine eval0_00
);

is +(my $v = mkv(X => y => 'z')), [ X => [ y => 'z' ] ];

is type($v), 'X';

is rtype($v), 'y';

is raw($v), 'z';

my $abc_list = list map mkv(String00 => string => $_), qw(a b c);

is raw(car($abc_list)), 'a';

is raw(car(cdr $abc_list)), 'b';

is raw(car($abc_list, 1)), 'b';

is raw(car(cdr($abc_list, 2))), 'c';

{
  my ($x, $y) = uncons($abc_list);
  is raw($x), 'a';
  is raw(car $y), 'b';
}

is [ map raw($_), flatten($abc_list) ], [ qw(a b c) ];

my $scope = make_scope({ x => mkv(Bool00 => bool => 1) });

is car(combine($scope, deref($scope), list mkv(String00 => chars => 'x')), 1),
  [ Bool00 => [ bool => 1 ] ];

is eval0_00($scope, mkv(Name00 => chars => 'x')),
  [ Bool00 => [ bool => 1 ] ];

is eval0_00($scope, mkv(String00 => chars => 'foo')),
  [ String00 => [ chars => 'foo' ] ];

is eval0_00($scope, list(
      mkv(Name00 => chars => 'x'),
      mkv(String00 => chars => 'foo')
  )),
  list(mkv(Bool00 => bool => 1), mkv(String00 => chars => 'foo'));

my $concat = mkv(Fexpr00 => native => sub ($scope, $args) {
  mkv String00 => chars => join '', map raw($_), flatten($args);
});

my $foobar_list = list(map mkv(String00 => chars => $_), qw(foo bar));

is eval0_00($scope, mkv(Call00 => cons => $concat, $foobar_list)),
  mkv(String00 => chars => 'foobar');

my $fid = mkv(Fexpr00 => cons =>
  $scope,
  mkv(Name00 => chars => 'args'),
);

is eval0_00($scope, mkv(Call00 => cons => $fid, $foobar_list)),
  $foobar_list;

done_testing;
