use Mojo::Base -strict, -signatures;
use Test2::V0;

use Mojo::JSON qw(decode_json);
use XCL0::00::Parser qw(parse_string);

my @test_text = do {
  my $idx = 0;
  map [ $idx++, $_ ], <DATA>;
};

my @tests;

while (my $start = shift @test_text) {
  my ($idx, $line) = @$start;
  die unless $line =~ /^\$ (.*)$/;
  my (@inlines, @outlines) = ($1);
  my $t = { idx => $idx, in => \@inlines, out => \@outlines };
  while (@test_text and $test_text[0][1] =~ /^> (.*)$/) {
    shift @test_text; push @inlines, $1
  }
  while (@test_text and $test_text[0][1] =~ /^< (.*)$/) {
    shift @test_text; push @outlines, $1
  }
  push @tests, $t;
}

foreach my $test (@tests) {
  is 
    parse_string(join "\n", @{$test->{in}}),
    decode_json(join "\n", @{$test->{out}}),
    "Data test ".$test->{idx};
}

done_testing;

__DATA__
$ x
< [ [ "Name", [ "string", "x" ] ] ]
$ 'foo'
< [ [ "String", [ "string", "foo" ] ] ]
$ [ x 'foo' ]
< [ [
<     "Call", [
<       "cons", [ "Name", [ "string", "x" ] ], [
<         "List",
<         [ "cons", [ "String", [ "string", "foo" ] ], [ "List", [ "nil" ] ] ]
<       ]
<     ]
< ] ]
$ x [ y [ z 'foo' ] ]
< [
<   [ "Name", [ "string", "x" ] ], [
<     "Call", [
<       "cons", [ "Name", [ "string", "y" ] ], [
<         "List", [
<           "cons", [
<             "Call", [
<               "cons", [ "Name", [ "string", "z" ] ], [
<                 "List", [
<                   "cons", [ "String", [ "string", "foo" ] ],
<                   [ "List", [ "nil" ] ]
<                 ]
<               ]
<             ]
<           ],
<           [ "List", [ "nil" ] ]
<         ]
<       ]
<     ]
<   ]
< ]
