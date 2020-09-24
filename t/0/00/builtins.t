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
> 'String'
$ _rtype 'foo'
> 'chars'
$ _rmkraw 'String' 'chars' 'foo'
> 'foo'
$ _rmkref 'Call' 'cons' 'x' [ _list 'y' ]
> [ 'x' 'y' ]
$ _rmkref 'Call' 'cons' [ _escape _type ] [ _list 'y' ]
> [ _type 'y' ]
$ _id 'foo'
> 'foo'
$ _string_concat 'foo' 'bar'
> 'foobar'
$ _eq_chars 'foo' 'bar'
> false
$ _eq_chars 'foo' 'foo'
> true
$ _gt_chars 'x' 'a'
> true
$ _gt_chars 'x' 'x'
> false
$ _gt_chars 'a' 'x'
> false
$ _eq_bool [ _rtrue ] [ _rtrue ]
> true
$ _eq_bool [ _rfalse ] [ _rfalse ]
> true
$ _eq_bool [ _rfalse ] [ _rtrue ]
> false
$ _eq_bool [ _rtrue ] [ _rfalse ]
> false
$ _rnil? [ _rmknil 'List' ]
> true
$ _rnil? [ _list ]
> true
$ _rtrue; _rfalse
> false
$ [ _rmkref 'Fexpr' 'cons' [ _getscope ] [ _escape [ _car args ] ] ] 'x' 'y'
> 'x'
$ _wutcol [ _rtrue ] 'x' 'y'
> 'x'
$ _wutcol [ _rfalse ] 'x' 'y'
> 'y'
$ _eq_chars 'a' [ [ _rmkref 'Fexpr' 'cons' [ _getscope ] [ _escape [
<   _wutcol [ _eq_chars 'x' [ _car args ] ] 'a' 'b'
< ] ] ] 'x' ]
> true
$ [ _rmkref 'Fexpr' 'cons' [ _getscope ] [ _escape [
<   _wutcol [ _eq_chars 'x' [ _car args ] ] 'a' 'b'
< ] ] ] 'y'
> 'b'
