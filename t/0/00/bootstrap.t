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
#         (name, $$newvalue)
#         [ $$[deref callscope] name ]
#     } ]
#   }
# ]
$ [ _wrap [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>   _eval0_00 callscope [ _rmkcons 'Call00'
>    [ _car args ] [ _list 'define' [ _car args ] ]
>   ]
> ] ] ] ]
>   [ _wrap [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>     _set callscope
>       [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ]
>         [ _rmkcons 'Call00' _wutcol [ _list
>           [ _rmkcons 'Call00'
>               _eq_string [ _list
>                 [ _rmkcons 'Call00' _car [ _list [ _escape args ] ] ]
>                 [ _car args ] ] ]
>             [ _rmkcons 'Call00' _list [
>                 _list [ _car args ]
>                 [ _rmkcons 'Call00' _escape [ _list [ _car [ _cdr args ] ] ] ]
>             ] ]
>             [ _rmkcons 'Call00'
>               [ _wrap [ _deref callscope ] ]
>               [ _list
>                 [ _rmkcons 'Call00' _car [ _list [ _escape args ] ] ] ] ]
>         ] ]
>       ];
>       _list
>   ] ] ] ]
< ()
$ define 'foo' 'Fu'; _id foo
< 'Fu'
$ define '_fexpr' [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>   _rmkcons 'Fexpr00' [ _deref callscope ] [ _car args ]
> ] ] ]
< ()
$ define '_call' [ _wrap [ _fexpr [
>   _rmkcons 'Call00' [ _car args ] [ _cdr args ]
> ] ] ]
< ()
$ _eval0_00 [ _getscope ] [ _call _id foo ]
< 'Fu'
$ define 'call-scoped' [ _fexpr [
>   define 'inner-scope' [ _rmkvar 'Scope00' [ _deref callscope ] ];
>   _eval0_00 inner-scope [ _car args ]
> ] ]
< ()
$ call-scoped [ define 'bar' 'Yorkie'; _id bar ]
< 'Yorkie'
$ _id bar
! No such name: bar
# define _defmulti [ fexpr (names, values) {
#   callscope.eval [ call \define [ first names ] [ first values ] ];
#   thisfunc [ rest names ] [ rest values ];
# } ]
$ define '_defmulti' [ _fexpr [
>   define 'names' [ _car args ];
>   define 'values' [ _eval0_00 callscope [ _car [ _cdr args ] ] ];
>   _eval0_00 callscope [ _call define [ _val [ _car names ] ] [ _car values ] ];
>   _wutcol [ _rnil? [ _cdr names ] ]
>     [ _list ]
>     [ _eval0_00 callscope
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
>   _eval0_00 callscope [ _call _fexpr [ _call _progn unpack body ] ]
> ] ]
< ()
$ [ fexpr [ x y ] [ _concat_string x y ] ] 'foo' 'bar'
< 'foobar'
$ define '_listo' [ _fexpr args ]
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
