package XCL0::00::GenRaw;

use Mojo::Base -base, -signatures;
use List::Util qw(reduce);
use Exporter 'import';

our @EXPORT = qw(L S N C);

sub L (@el) {
  reduce { [ List => [ cons => $b, $a ] ] }
    [ List => [ 'nil' ],
    reverse @el;
}

sub S ($v) { [ String => [ string => $v ] ] }

sub N ($v) { [ Name => [ string => $v ] ] }

sub C ($inv, @el) {
  die unless $inv;
  [ Call => [ cons => $inv, L(@el) ] ];
}

1;
