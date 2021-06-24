use NXCL::Test;
use NXCL::DataTest;
use NXCL::Reader;
use NXCL::Expander;
use JSON::Dumper::Compact jdc => { max_width => 76 };

my $r = NXCL::Reader->new;

my $e = NXCL::Expander->new(
  maker => sub { \@_ },
);

data_test \*DATA, sub ($v) {
  (jdc $e->expand($r->parse(script => $v))) =~ s/\n\z//r;
};

done_testing;

__DATA__
$ if
< [ "Call", [ "Name", "if" ] ]
$ x.y
< [
<   "Call",
<   [ "Compound", [ "Name", "x" ], [ "Name", "." ], [ "Name", "y" ] ],
< ]
$ x + y
< [
<   "Call", [
<     "Combine", [ "Name", "x" ],
<     [ "List", [ "Name", "+" ], [ "Name", "y" ] ],
<   ],
< ]
$ x.y()
< [
<   "Call", [
<     "Compound", [ "Name", "x" ], [ "Name", "." ], [ "Name", "y" ],
<     [ "List" ],
<   ],
< ]
$ if [ lst.count() > 1 ] {
>   say 'multiple';
> }
< [
<   "Call", [
<     "Compound", [ "Name", "if" ], [
<       "Call", [
<         "Combine", [
<           "Compound", [ "Name", "lst" ], [ "Name", "." ],
<           [ "Name", "count" ], [ "List" ],
<         ],
<         [ "List", [ "Name", ">" ], [ "Int", 1 ] ],
<       ],
<     ], [
<       "BlockProto",
<       [ "Combine", [ "Name", "say" ], [ "List", [ "String", "multiple" ] ] ],
<     ],
<   ],
< ]
$ 'foo\ bar\' baz\\'
< [ "Call", [ "String", "foo\\ bar' baz\\" ] ]
