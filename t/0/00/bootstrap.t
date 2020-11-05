use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Reader qw(read_string);
use XCL0::00::Writer qw(write_string);
use XCL0::00::Runtime qw(eval0_00);
use XCL0::00::Builtins qw(builtin_scope);
use XCL0::DataTest;

my $scope = builtin_scope();

data_test \*DATA, sub ($v) {
  write_string(eval0_00($scope, read_string $v))
};

done_testing;

__DATA__
$ _type 'foo'
< 'String'
# [
#   lambda (definer) { scope.eval \$[ $$definer 'define' $$definer ] }
#   lambda (newname, newvalue) {
#     _set scope [ lambda (name) \${
#       ?: [ name == $$newname ]
#         $$newvalue
#         [ $$[deref scope] name ]
#     } ]
#   }
# ]
$ [ _wrap [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
>   _eval0_00 scope [ _rmkcons 'Call'
>    [ _car args ] [ _list 'define' [ _car args ] ]
>   ]
> ] ] ] ]
>   [ _wrap [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
>     _set scope
>       [ _wrap [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ]
>         [ _rmkcons 'Call' _wutcol [ _list
>           [ _rmkcons 'Call' _eq_string
>             [ _list [ _escape [ _car args ] ] [ _car args ] ] ]
>             [ _rmkcons 'Call' _escape [ _list [ _car [ _cdr args ] ] ] ]
>             [ _rmkcons 'Call'
>               [ _deref scope ]
>               [ _list [ _escape [ _car args ] ] ] ]
>         ] ]
>       ] ];
>       _list
>   ] ] ] ]
< ()
$ define 'foo' 'Fu'; _id foo
< 'Fu'
$ define '_fexpr' [ _rmkcons 'Fexpr' [ _deref [ _getscope ] ] [ _escape [
>   _rmkcons 'Fexpr' [ _deref scope ] [ _car args ]
> ] ] ]
< ()
$ define '_call' [ _wrap [ _fexpr [
>   _rmkcons 'Call' [ _car args ] [ _cdr args ]
> ] ] ]
< ()
$ _eval0_00 [ _getscope ] [ _call _id foo ]
< 'Fu'
$ define 'call-scoped' [ _fexpr [
>   define 'inner-scope' [ _rmkvar 'Scope' [ _deref scope ] ];
>   _eval0_00 inner-scope [ _car args ]
> ] ]
< ()
$ call-scoped [ define 'bar' 'Yorkie'; _id bar ]
< 'Yorkie'
$ _id bar
! No such name: bar
# define _defmulti [ fexpr (names, values) {
#   scope.eval [ call \define [ first names ] [ first values ] ];
#   thisfunc [ rest names ] [ rest values ];
# } ]
$ define '_defmulti' [ _fexpr [
>   define 'names' [ _car args ];
>   define 'values' [ _eval0_00 scope [ _car [ _cdr args ] ] ];
>   _eval0_00 scope [ _call define [ _val [ _car names ] ] [ _car values ] ];
>   _wutcol [ _rnil? [ _cdr names ] ]
>     [ _list ]
>     [ _eval0_00 scope
>       [ _call thisfunc [ _cdr names ] [ _call _escape [ _cdr values ] ] ] ]
> ] ]
< ()
$ call-scoped [
>   _defmulti [ x y z ] [ _list 'x1' 'y2' 'z3' ];
>   _list z y x
> ]
< ('z3', 'y2', 'x1')
$ define 'fexpr' [ _fexpr [
>   define 'arglist' [ _car args ];
>   define 'body' [ _car [ _cdr args ] ];
>   define 'unpack' [ _call _defmulti arglist [ _escape args ] ];
>   _eval0_00 scope [ _call _fexpr [ _call _progn unpack body ] ]
> ] ]
< ()
$ [ fexpr [ x y ] [ _concat_string x y ] ] 'foo' 'bar'
< 'foobar'
$ _eval0_00 [ _getscope ]
>   [ _call
>     [ _call fexpr [ _listo x y ] [ _escape [ _concat_string x y ] ] ]
>     'foo' 'bar' ]
< 'foobar'
