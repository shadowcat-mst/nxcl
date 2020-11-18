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
< 'String00'
# [
#   lambda (definer) { callscope.eval \$[ $$definer 'define' $$definer ] }
#   lambda (newname, newvalue) {
#     _set callscope [ lambda (name) \${
#       ?: [ name == $$newname ]
#         $$newvalue
#         [ $$[deref callscope] name ]
#     } ]
#   }
# ]
$ [ _wrap [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>   _eval0_00 callscope [ _rmkcons 'Call00'
>    [ _car thisargs ] [ _list 'define' [ _car thisargs ] ]
>   ]
> ] ] ] ]
>   [ _wrap [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>     _set callscope
>       [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ]
>         [ _rmkcons 'Call00' _wutcol [ _list
>           [ _rmkcons 'Call00'
>               _eq_string [ _list
>                 [ _rmkcons 'Call00' _car [ _list [ _escape thisargs ] ] ]
>                 [ _car thisargs ] ] ]
>             [ _rmkcons 'Call00' _list [
>                 _list [ _car thisargs ]
>                 [ _rmkcons 'Call00' _escape [ _list [ _car [ _cdr thisargs ] ] ] ]
>             ] ]
>             [ _rmkcons 'Call00'
>               [ _wrap [ _deref callscope ] ]
>               [ _list
>                 [ _rmkcons 'Call00' _car [ _list [ _escape thisargs ] ] ] ] ]
>         ] ]
>       ];
>       _list
>   ] ] ] ]
< ()
$ define 'foo' 'Fu'; _id foo
< 'Fu'
$ define '_fexpr' [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>    _rmkcons 'Fexpr00' [ _deref callscope ] [ _car thisargs ]
> ] ] ]
< ()
$ define '_call' [ _wrap [ _fexpr [
>   _rmkcons 'Call00' [ _car thisargs ] [ _cdr thisargs ]
> ] ] ]
< ()
$ define '_lambda' [ _fexpr [
>   _wrap [
>     _eval0_00 callscope [ _call _fexpr [ _car thisargs ] ]
>   ]
> ] ]
< ()
$ define 'kvstore' [ [ _wrap _lambda ] [
>   _call [ _wrap _fexpr ] [
>       _call _call _wutcol
>         [ _call _call _rnil? [ _call _escape [ _escape thisargs ] ] ]
>         [ _escape thisargs ]
>         [ _call _rmkcons 'Call00'
>           _skvlis
>           [ _call _rmkcons 'List00'
>             [ _call _call _car [ _call _escape [ _escape thisargs ] ] ]
>             [ _escape thisargs ] ] ]
>   ]
> ] ]
< ()
$ [ _car [ _cdr [
>   [ kvstore [ _list ] [ _list ] [ _deref [ _scope0_00 ] ] ] '_id'
> ] ] ] 'foo'
< 'foo'
$ [ kvstore [ _list 'x' ] [ _list 'y' ] [ _deref [ _scope0_00 ] ] ] 'x'
< ('x', 'y')
$ _car [ [ kvstore [ _list 'x' ] [ _list 'y' ] [ _deref [ _scope0_00 ] ] ] ]
< ('x')
$ _car [ _cdr [
>   [ kvstore [ _list 'x' ] [ _list 'y' ] [ _deref [ _scope0_00 ] ] ]
> ] ]
< ('y')
# let kvadd = ((klis, vlis, next), name, value) => {
#   kvstore [ cons name klis ] [ cons value vlis ] next
# }
$ define 'kvadd' [ [ _wrap _lambda ] [
>   _call kvstore
#     # cons
>     [ _call _rmkcons 'List00'
#       # name
>       [ _call _car [ _call _cdr
>         [ _escape thisargs ] ] ]
#       # klis
>       [ _call _car [ _call _car [ _escape thisargs ] ] ] ]
#     # cons
>     [ _call _rmkcons 'List00'
#       # value
>       [ _call _car [ _call _cdr [ _call _cdr
>         [ _escape thisargs ] ] ] ]
#       # vlis
>       [ _call _car [ _call _cdr [ _call _car [ _escape thisargs ] ] ] ] ]
#     # next
>     [ _call _car [ _call _cdr [ _call _cdr [ _call _car
>       [ _escape thisargs ] ] ] ] ]
> ] ]
< ()
$ [ kvadd [ [ kvstore [ _list ] [ _list ] _list ] ] 'x' 'y' ] 'x'
< ('x', 'y')
$ define 'kvdef' [ _lambda [
>   _set callscope [
>     kvadd [ [ _deref callscope ] ] [ _car thisargs ] [ _car [ _cdr thisargs ] ]
>   ];
>   _list
> ] ]
< ()
$ _set [ _getscope ] [
>   kvstore
>     [ _list 'define' 'kvstore' 'kvadd' ]
>     [ _list kvdef kvstore kvadd ]
>     [ _deref [ _scope0_00 ] ]
> ]; _list
< ()
$ _id foo
! No such name: foo
$ define 'foo' 'Fu'; _id foo
< 'Fu'
$ define '_fexpr' [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>    _rmkcons 'Fexpr00' [ _deref callscope ] [ _car thisargs ]
> ] ] ]
< ()
$ define '_call' [ _wrap [ _fexpr [
>   _rmkcons 'Call00' [ _car thisargs ] [ _cdr thisargs ]
> ] ] ]
< ()
$ _eval0_00 [ _getscope ] [ _call _id foo ]
< 'Fu'
$ define 'call-scoped' [ _fexpr [
>   define 'inner-scope' [ _rmkvar 'Scope00' [ _deref callscope ] ];
>   _eval0_00 inner-scope [ _car thisargs ]
> ] ]
< ()
$ call-scoped [ define 'bar' 'Yorkie'; _id bar ]
< 'Yorkie'
$ _id bar
! No such name: bar
