use NXCL::Test;
use NXCL::DataTest;
use NXCL::01::Reader;
use JSON::Dumper::Compact qw(jdc);

my $r = NXCL::01::Reader->new;

data_test \*DATA, sub ($v) {
  (jdc $r->from_string($v)) =~ s/\n\z//r;
};

done_testing;

__DATA__
$ if
< [ "script", [ [ "expr", [ [ "compound", [ [ "word", "if" ] ] ] ] ] ] ]
$ x.y
< [
<   "script", [ [
<       "expr", [ [
<           "compound",
<           [ [ "word", "x" ], [ "symbol", "." ], [ "word", "y" ] ],
<       ] ],
<   ] ],
< ]
$ x + y
< [
<   "script", [ [
<       "expr", [
<         [ "compound", [ [ "word", "x" ] ] ],
<         [ "compound", [ [ "symbol", "+" ] ] ],
<         [ "compound", [ [ "word", "y" ] ] ],
<       ],
<   ] ],
< ]
$ x.y()
< [
<   "script", [ [
<       "expr", [ [
<           "compound", [
<             [ "word", "x" ], [ "symbol", "." ], [ "word", "y" ],
<             [ "list", [] ],
<           ],
<       ] ],
<   ] ],
< ]
$ if [ lst.length() > 1 ] {
>   say 'multiple';
> }
< ???
