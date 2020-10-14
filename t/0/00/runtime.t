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

my $abc_list = list map mkv(String => string => $_), qw(a b c);

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

my $scope = make_scope({ x => mkv(Bool => bool => 1) });

is combine($scope, deref($scope), list mkv(String => chars => 'x')),
  [ Bool => [ bool => 1 ] ];

is eval0_00($scope, mkv(Name => chars => 'x')),
  [ Bool => [ bool => 1 ] ];

is eval0_00($scope, mkv(String => chars => 'foo')),
  [ String => [ chars => 'foo' ] ];

is eval0_00($scope, list(
      mkv(Name => chars => 'x'),
      mkv(String => chars => 'foo')
  )),
  list(mkv(Bool => bool => 1), mkv(String => chars => 'foo'));

my $concat = mkv(Native => native => sub ($scope, $args) {
  mkv String => chars => join '', map raw($_), flatten($args);
});

my $foobar_list = list(map mkv(String => chars => $_), qw(foo bar));

is eval0_00($scope, mkv(Call => cons => $concat, $foobar_list)),
  mkv(String => chars => 'foobar');

my $fid = mkv(Fexpr => cons =>
  $scope,
  mkv(Name => chars => 'args'),
);

is eval0_00($scope, mkv(Call => cons => $fid, $foobar_list)),
  $foobar_list;

done_testing;
