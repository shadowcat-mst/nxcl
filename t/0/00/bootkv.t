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
$ define '_call' [ _wrap [ [ _wrap _fexpr ] [
>   _rmkcons 'Call00'
>     _rmkcons
>     [ _list
>       'Call00'
>       [ _rmkcons 'Call00' _car [ _list [ _escape thisargs ] ] ]
>       [ _rmkcons 'Call00' _cdr [ _list [ _escape thisargs ] ] ] ]
> ] ] ]
< ()
$ define '_lambda' [ _fexpr [
>   _wrap [
>     _eval0_00 callscope [ _call _fexpr [ _car thisargs ] ]
>   ]
> ] ]
< ()
$ define '_listo' [ _fexpr thisargs ]
< ()
# let _mapcons = (f, l) => {
#   ?: [ empty? l ]
#     ()
#   cons [ f [ first l ] ] [ thisfunc f [ rest l ] ]
# }
$ define '_mapcons' [ _wrap [ [ _wrap _fexpr ] [
>   _call _wutcol
>     [ _call _rnil? [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ]
>     [ _call _list ]
>     [ _call _rmkcons 'List00'
>       [ _call [ _call _car [ _escape thisargs ] ]
>         [ _call _car [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ] ]
>       [ _call [ _call _wrap [ _escape thisfunc ] ]
>           [ _call _car [ _escape thisargs ] ]
>           [ _call _cdr [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ]
>       ] ]
> ] ] ]
< ()
$ _mapcons _val [ _listo x y z ]
< ('x', 'y', 'z')
$ define '_escapify' [ [ _wrap _lambda ] [
>  _call _call _escape [ _call _car [ _escape thisargs ] ]
> ] ];
< ()
$ _escapify [ _escape x ]
< [ Bif00(_escape) x ]
$ define 'kvstore' [ [ _wrap _lambda ] [
>   _call [ _wrap _fexpr ] [
>       _call _call _wutcol
>         [ _call _call _rnil? [ _call _escape [ _escape thisargs ] ] ]
>         [ _escape [ _call _escape thisargs ] ]
>         [ _call _rmkcons 'Call00'
>           _skvlis
>           [ _call _list
>             [ _call _call _car [ _call _escape [ _escape thisargs ] ] ]
>             [ _call _car [ _escape thisargs ] ]
>             [ _call _call _escape [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ]
>             [ _call _car [ _call _cdr [ _call _cdr [ _escape thisargs ] ] ] ] ] ]
>   ]
> ] ];
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
$ define '_mapcons' [ _wrap [ [ _wrap _fexpr ] [
>   _call _wutcol
>     [ _call _rnil? [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ]
>     [ _call _list ]
>     [ _call _rmkcons 'List00'
>       [ _call [ _call _car [ _escape thisargs ] ]
>         [ _call _car [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ] ]
>       [ _call [ _call _wrap [ _escape thisfunc ] ]
>           [ _call _car [ _escape thisargs ] ]
>           [ _call _cdr [ _call _car [ _call _cdr [ _escape thisargs ] ] ] ]
>       ] ]
> ] ] ]
< ()
$ define 'fexpr' [ _fexpr [
>   _set [ _getscope ]
>     [ kvstore [ _list ] [ _list ] [ _deref [ _getscope ] ] ];
>   define 'argnames' [ _mapcons _val [ _car thisargs ] ];
>   define 'body' [ _car [ _cdr thisargs ] ];
>   define 'unpack' [ _call _set [ _call _getscope ]
>     [ _call kvstore argnames
>       [ _escape thisargs ] [ _call _deref [ _call _getscope ] ] ] ];
>   _eval0_00 callscope [ _call _fexpr [ _call _progn unpack body ] ]
> ] ]
< ()
$ [ fexpr [ x y ] [ _concat_string x y ] ] 'foo' 'bar'
< 'foobar'
$ define '_listo' [ _fexpr thisargs ]
< ()
$ _eval0_00 [ _getscope ]
>   [ _call
>     [ _call fexpr [ _listo x y ] [ _escape [ _concat_string x y ] ] ]
>     'foo' 'bar' ]
< 'foobar'
$ define 'alist-get-entry' [ _wrap [ fexpr [ alist key ] [
>   _wutcol [ _rnil? alist ]
>     [ _panic 'No such key' key ]
>     [ _wutcol [ _eq_string [ _car [ _car alist ] ] key ]
>       [ _car alist ]
>       [ [ _wrap thisfunc ] [ _cdr alist ] key ] ]
> ] ] ]
< ()
$ alist-get-entry [_list] 'foo'
! No such key: 'foo'
$ define 'ex-alist' [ _list [ _list 'x' 'x1' ] [ _list 'z' 'z1' ] ]
< ()
$ alist-get-entry ex-alist 'z'
< ('z', 'z1')
$ define 'alist-get-value' [ _wrap [ fexpr [ alist key ] [
>   _car [ _cdr [ alist-get-entry alist key ] ]
> ] ] ]
< ()
$ alist-get-value ex-alist 'z'
< 'z1'
# let alist-set-value (alist, key, value) {
#   ?: [ empty? alist ]
#     [ list [ list key value ] ]
#   ?: [ eq [ car [ car alist ] ] key ]
#     [ cons [ list key value ] [ cdr alist ] ]
#   ?: [ gt [ car [ car alist ] ] key ]
#     [ cons [ list key value ] alist ]
#   cons [ car alist ] [ thisfunc [ cdr alist ] key value ]
# }
$ define 'alist-set-value' [ _wrap [ fexpr [ alist key value ] [
>   _wutcol [ _rnil? alist ]
>     [ _list [ _list key value ] ]
>     [ define 'firstkey' [ _car [ _car alist ] ];
>       _wutcol [ _eq_string firstkey key ]
>         [ _rmkcons 'List00' [ _list key value ] [ _cdr alist ] ]
>         [ _wutcol [ _gt_string firstkey key ]
>           [ _rmkcons 'List00' [ _list key value ] alist ]
>           [ _rmkcons 'List00' [ _car alist ]
>             [ [ _wrap thisfunc ] [ _cdr alist ] key value ] ] ] ]
> ] ] ]
< ()
$ alist-set-value [_list] 'a' 'a1'
< (('a', 'a1'))
$ alist-set-value ex-alist 'y' 'y1'
< (('x', 'x1'), ('y', 'y1'), ('z', 'z1'))
$ alist-set-value ex-alist 'z' 'z2'
< (('x', 'x1'), ('z', 'z2'))
