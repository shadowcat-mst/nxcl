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
