use Mojo::Base -strict, -signatures;
use Test2::V0;

use XCL0::00::Reader qw(read_string);
use XCL0::00::Writer qw(write_string);

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
    write_string(read_string(join "\n", @{$test->{in}})),
    join("\n", @{$test->{out}}),
    "Data test ".$test->{idx};
}

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
