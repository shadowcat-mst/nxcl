use Mojo::Base -strict, -signatures;

use XCL0::00::GenJ;

print genj C(N 'foo', S 'bar', L(S 'a', S 'b'));

1;
