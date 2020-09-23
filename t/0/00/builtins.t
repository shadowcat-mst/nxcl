use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Reader qw(read_string);
use XCL0::00::Writer qw(write_string);
use XCL0::00::Runtime qw(eval_inscope);
use XCL0::00::Builtins qw(builtin_scope);
use XCL0::DataTest;

data_test \*DATA, sub ($v) {
  write_string(eval_inscope(builtin_scope(), read_string $v))
};

done_testing;

__DATA__
$ _type 'foo'
< 'String'
$ _rmkraw 'String' 'chars' 'foo'
< 'foo'
$ _rmkref 'Call' 'cons' 'x' [ _list 'y' ]
< [ 'x' 'y' ]
$ _rmkref 'Call' 'cons' [ _escape _type ] [ _list 'y' ]
< [ _type 'y' ]
$ _string_concat 'foo' 'bar'
< 'foobar'
$ _eq_chars 'foo' 'bar'
< false
$ _eq_chars 'foo' 'foo'
< true
$ _gt_chars 'x' 'a'
< true
$ _gt_chars 'x' 'x'
< false
$ _gt_chars 'a' 'x'
< false
$ _eq_bool [ _eq_chars 'x' 'x' ] [ _eq_chars 'x' 'x' ]
< true
$ _eq_bool [ _eq_chars 'x' 'x' ] [ _eq_chars 'x' 'y' ]
< false
$ _eq_bool [ _eq_chars 'x' 'y' ] [ _eq_chars 'y' 'y' ]
< false
$ _eq_bool [ _eq_chars 'y' 'y' ] [ _eq_chars 'y' 'y' ]
< true
