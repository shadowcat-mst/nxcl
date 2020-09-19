use Test2::V0;
use Mojo::Base -strict, -signatures;

use XCL0::00::Reader qw(read_string);
use XCL0::00::Writer qw(write_string);
use XCL0::DataTest;

data_test \*DATA, sub ($v) { write_string(read_string $v) };

done_testing;

__DATA__
$ x
< [ x ]
$ 'foo'
< [ 'foo' ]
$ [ x 'foo' ]
< [ [ x 'foo' ] ]
$ x [ y [ z 'foo' ] ]
< [ x [ y [ z 'foo' ] ] ]
