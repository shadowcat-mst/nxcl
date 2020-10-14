use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Reader qw(read_string);
use XCL0::00::Writer qw(write_string);
use XCL0::00::Runtime qw(eval0_00);
use XCL0::00::Builtins qw(builtin_scope);
use XCL0::DataTest;

data_test \*DATA, sub ($v) {
  write_string(eval0_00(builtin_scope(), read_string $v))
};

done_testing;

__DATA__
$ _type 'foo'
> 'String'
$ _rtype 'foo'
> 'chars'
$ _rmkchars 'String' 'foo'
> 'foo'
$ _rmkcons 'Call' 'x' [ _list 'y' ]
> [ 'x' 'y' ]
$ _rmkcons 'Call' [ _escape _type ] [ _list 'y' ]
> [ _type 'y' ]
$ _id 'foo'
> 'foo'
$ _concat_string 'foo' 'bar'
> 'foobar'
$ _eq_string 'foo' 'bar'
> false
$ _eq_string 'foo' 'foo'
> true
$ _gt_string 'x' 'a'
> true
$ _gt_string 'x' 'x'
> false
$ _gt_string 'a' 'x'
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
# fexpr (x, y) { x } -> 'x'
$ [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [ _car args ] ] ] 'x' 'y'
> 'x'
$ _wutcol [ _rtrue ] 'x' 'y'
> 'x'
$ _wutcol [ _rfalse ] 'x' 'y'
> 'y'
# == 'a' [ fexpr (s) { ?: [ s == 'x' ] 'a' 'b' } 'x' ]
$ _eq_string 'a' [ [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<   _wutcol [ _eq_string 'x' [ _car args ] ] 'a' 'b'
< ] ] ] 'x' ]
> true
# fexpr (s) { ?: [ s == 'x' ] 'a' 'b' } 'y'
$ [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<   _wutcol [ _eq_string 'x' [ _car args ] ] 'a' 'b'
< ] ] ] 'y'
> 'b'
# _type 'foo'
$ [ [ _deref [ _getscope ] ] '_type' ] 'foo'
> 'String'
$ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<   [ _deref [ _getscope ] ] [ _car args ]
< ] ]
> Fexpr()
# [ fexpr (x) { [ _deref [ _getscope ] ] x } '_type ] 'foo;
$ [
<   [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<     [ _deref [ _getscope ] ] [ _car args ]
<   ] ] ] '_type'
< ] 'foo'
> 'String'
# _set [ _getscope ] fexpr (x) { [ _deref [ _getscope ] ] x }; _type 'foo'
$ _set [ _getscope ]
<   [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<     [ _deref [ _getscope ] ] [ _car args ]
<   ] ] ];
< _type 'foo'
> 'String'
# _set [ _getscope ] fexpr (x) {
#   ?: [ _eq_string x 'x' ]
#     'is_x'
#   [ _deref [ _getscope ] ] x
# }
$ _set [ _getscope ]
<   [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<     _wutcol [ _eq_string [ _car args ] 'x' ]
<      'is_x'
<    [ [ _deref [ _getscope ] ] [ _car args ] ]
<   ] ] ];
< _id x
> 'is_x'
# [ fexpr (x) { fexpr (y) [ call _concat_string 'foo' y ] } ] 'bar'
$ [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [
<       _rmkcons 'Call' _concat_string
<         [ _list 'foo' [ _escape [ _car args ] ] ]
< ] ] 'bar'
> 'foobar'
# [ [ fexpr (x) { fexpr (y) { _concat_string x y } } ] 'foo' ] 'bar'
$ [
<   [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<     _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [
<        _rmkcons 'Call' _concat_string
<          [ _list [ _car args ] [ _escape [ _car args ] ] ]
<     ]
<   ] ] ]
<   'foo'
< ]
< 'bar'
> 'foobar'
# lambda (x, y) {
#   ?: [ empty? x ]
#     ''
#   ?: [ x(0)(0) == y ]
#     x(0)(1)
#   thisfunc [ rest x ] y
# }
# thisfunc ( ('x', '1'), ('y', '2') ) 'x'
$ [ _wrap [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<   _wutcol [ _rnil? [ _car args ] ]
<     ''
<     [ _wutcol
<         [ _eq_string [ _car [ _car [ _car args ] ] ] [ _car [ _cdr args ] ] ]
<         [ _car [ _cdr [ _car [ _car args ] ] ] ]
<         [ [ _wrap thisfunc ] [ _cdr [ _car args ] ] [ _car [ _cdr args ] ] ]
<     ]
< ] ] ] ]
< [ _list [ _list 'x' '1' ] [ _list 'y' '2' ] ] 'x'
> '1'
$ [ _wrap [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<   _wutcol [ _rnil? [ _car args ] ]
<     ''
<     [ _wutcol
<         [ _eq_string [ _car [ _car [ _car args ] ] ] [ _car [ _cdr args ] ] ]
<         [ _car [ _cdr [ _car [ _car args ] ] ] ]
<         [ [ _wrap thisfunc ] [ _cdr [ _car args ] ] [ _car [ _cdr args ] ] ]
<     ]
< ] ] ] ]
< [ _list [ _list 'x' '1' ] [ _list 'y' '2' ] ] 'y'
> '2'
$ [ _wrap [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
<   _wutcol [ _rnil? [ _car args ] ]
<     ''
<     [ _wutcol
<         [ _eq_string [ _car [ _car [ _car args ] ] ] [ _car [ _cdr args ] ] ]
<         [ _car [ _cdr [ _car [ _car args ] ] ] ]
<         [ [ _wrap thisfunc ] [ _cdr [ _car args ] ] [ _car [ _cdr args ] ] ]
<     ]
< ] ] ] ]
< [ _list [ _list 'x' '1' ] [ _list 'y' '2' ] ] 'z'
> ''
