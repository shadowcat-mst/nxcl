use NXCL::Test;

use NXCL::00::Reader qw(read_string);
use NXCL::00::Writer qw(write_string);
use NXCL::DataTest;

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
$ x [ y 'y1' ] [ z 'z1' ]
< [ x [ y 'y1' ] [ z 'z1' ] ]
$ x 'x1'; y 'y1';
< [ _progn [ x 'x1' ] [ y 'y1' ] ]
$ x [ y 'y1'; z 'z1' ]
< [ x [ _progn [ y 'y1' ] [ z 'z1' ] ] ]
$ x [ y [ a 'y1']; z 'z1' ]
< [ x [ _progn [ y [ a 'y1' ] ] [ z 'z1' ] ] ]
$ x [ [ y; z ] ]
< [ x [ [ _progn [ y ] [ z ] ] ] ]
