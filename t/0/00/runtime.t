use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Runtime qw(
  mkv type rtype raw car cdr list uncons flatten deref
  make_scope combine eval_inscope
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

my $scope = make_scope({ x => mkv(Bool => bool => 1) });

is combine($scope, deref($scope), list mkv(Name => chars => 'x')),
  [ Bool => [ bool => 1 ] ];

is eval_inscope($scope, mkv(Name => chars => 'x')),
  [ Bool => [ bool => 1 ] ];

is eval_inscope($scope, mkv(String => chars => 'foo')),
  [ String => [ chars => 'foo' ] ];

is eval_inscope($scope, list(
      mkv(Name => chars => 'x'),
      mkv(String => chars => 'foo')
  )),
  list(mkv(Bool => bool => 1), mkv(String => chars => 'foo'));

my $concat = mkv(Native => native => sub ($scope, $args) {
  mkv String => chars => join '', map raw($_), flatten($args);
});

is eval_inscope($scope, mkv(
    Call => cons => $concat, list(
      mkv(String => chars => 'foo'),
      mkv(String => chars => 'bar'),
    )
  )),
  mkv(String => chars => 'foobar');

done_testing;
