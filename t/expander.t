use NXCL::Test;
use NXCL::DataTest;
use NXCL::01::Reader;
use NXCL::01::Expander;
use JSON::Dumper::Compact jdc => { max_width => 76 };

my $r = NXCL::01::Reader->new;

my $e = NXCL::01::Expander->new(
  makers => { map {
    my $type = $_;
    ($type => sub { [ $type, @_ ] })
  } qw(Name Int List String BlockProto Call Combine Compound) }
);

data_test \*DATA, sub ($v) {
  (jdc $e->expand($r->from_string($v))) =~ s/\n\z//r;
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
