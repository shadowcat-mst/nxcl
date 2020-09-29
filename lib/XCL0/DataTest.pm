package XCL0::DataTest;

use Test2::V0;
use Mojo::Base -strict, -signatures;
use Exporter 'import';

our @EXPORT = qw(data_test);

sub data_test ($data, $evaluator) {
  my @test_text = do {
    my $idx = 0;
    map [ $idx++, $_ ], <$data>;
  };

  my @tests;

  while (my $start = shift @test_text) {
    my ($idx, $line) = @$start;
    next if $line =~ /^#/;
    die unless $line =~ /^\$ (.*)$/;
    my (@inlines, @outlines) = ($1);
    my $t = { idx => $idx, in => \@inlines, out => \@outlines };
    while (@test_text and $test_text[0][1] =~ /^< (.*)$/) {
      shift @test_text; push @inlines, $1
    }
    while (@test_text and $test_text[0][1] =~ /^> (.*)$/) {
      shift @test_text; push @outlines, $1
    }
    push @tests, $t;
  }


  foreach my $test (@tests) {
    my $src = join "\n", @{$test->{in}};
    diag "-> $src";
    my $out = $evaluator->($src);
    diag "<- $out";
    is 
      $out,
      join("\n", @{$test->{out}}),
      "Data test ".$test->{idx};
  }
}
