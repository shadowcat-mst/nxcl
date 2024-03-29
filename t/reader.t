use NXCL::Test;
use NXCL::DataTest;
use NXCL::Reader;
use JSON::Dumper::Compact qw(jdc);

my $r = NXCL::Reader->new;

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
$ if [ lst.count() > 1 ] {
>   say 'multiple';
> }
< [
<   "script", [ [
<       "expr", [ [
<           "compound", [
<             [ "word", "if" ], [
<               "call", [ [
<                   "expr", [
<                     [
<                       "compound", [
<                         [ "word", "lst" ], [ "symbol", "." ],
<                         [ "word", "count" ], [ "list", [] ],
<                       ],
<                     ],
<                     [ "compound", [ [ "symbol", ">" ] ] ],
<                     [ "compound", [ [ "uint", "1" ] ] ],
<                   ],
<               ] ],
<             ], [
<               "block", [ [
<                   "expr", [
<                     [ "compound", [ [ "word", "say" ] ] ],
<                     [ "compound", [ [ "string", "multiple" ] ] ],
<                   ],
<               ] ],
<             ],
<           ],
<       ] ],
<   ] ],
< ]
$ 'foo\ bar\' baz\\'
< [
<   "script",
<   [ [ "expr", [ [ "compound", [ [ "string", "foo\\ bar' baz\\" ] ] ] ] ] ],
< ]
