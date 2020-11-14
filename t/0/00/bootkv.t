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
#   lambda (definer) { scope.eval \$[ $$definer 'define' $$definer ] }
#   lambda (newname, newvalue) {
#     _set scope [ lambda (name) \${
#       ?: [ name == $$newname ]
#         $$newvalue
#         [ $$[deref scope] name ]
#     } ]
#   }
# ]
$ [ _wrap [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>   _eval0_00 scope [ _rmkcons 'Call00'
>    [ _car args ] [ _list 'define' [ _car args ] ]
>   ]
> ] ] ] ]
>   [ _wrap [ _rmkcons 'Fexpr00' [ _deref [ _getscope ] ] [ _escape [
>     _set scope
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
>               [ _wrap [ _deref scope ] ]
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
>    _rmkcons 'Fexpr00' [ _deref scope ] [ _car args ]
> ] ] ]
< ()
$ define '_call' [ _wrap [ _fexpr [
>   _rmkcons 'Call00' [ _car args ] [ _cdr args ]
> ] ] ]
< ()
$ define '_lambda' [ _fexpr [
>   _wrap [
>     _eval0_00 scope [ _call _fexpr [ _car args ] ]
>   ]
> ] ]
< ()
$ define 'kvstore' [ [ _wrap _lambda ] [
>   _call [ _wrap _fexpr ] [
>       _call _call _wutcol
>         [ _call _call _rnil? [ _call _escape [ _escape args ] ] ]
>         [ _escape args ]
>         [ _call _rmkcons 'Call00'
>           _skvlis
>           [ _call _rmkcons 'List00'
>             [ _call _call _car [ _call _escape [ _escape args ] ] ]
>             [ _escape args ] ] ]
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
>         [ _escape args ] ] ]
#       # klis
>       [ _call _car [ _call _car [ _escape args ] ] ] ]
#     # cons
>     [ _call _rmkcons 'List00'
#       # value
>       [ _call _car [ _call _cdr [ _call _cdr
>         [ _escape args ] ] ] ]
#       # vlis
>       [ _call _car [ _call _cdr [ _call _car [ _escape args ] ] ] ] ]
#     # next
>     [ _call _car [ _call _cdr [ _call _cdr [ _call _car
>       [ _escape args ] ] ] ] ]
> ] ]
< ()
$ [ kvadd [ [ kvstore [ _list ] [ _list ] _list ] ] 'x' 'y' ] 'x'
< ('x', 'y')
# define 'kvdef' [ _lambda [
#   _set scope [
#     kvadd [ [ _deref scope ] ] [ _car args ] [ _car [ _cdr args ] ]
#   ]
# ] ]
