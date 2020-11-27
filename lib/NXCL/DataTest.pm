package NXCL::DataTest;

use NXCL::Exporter;
use Test2::V0 -no_warnings => 1; # don't reactivate signatures warnings

our @EXPORT = qw(data_test);

sub data_test ($data, $evaluator) {
  my @test_text = do {
    my $idx = 0;
    grep $_->[1] !~ /^#/, map [ $idx++, $_ ], <$data>;
  };

  close $data;

  my @tests;

  while (my $start = shift @test_text) {
    my ($idx, $line) = @$start;
    die "Test case must start with $ line, not ${line}"
      unless $line =~ /^\$ (.*)$/;
    my (@inlines, @outlines, @errlines) = ($1);
    my $t = {
      idx => $idx,
      in => \@inlines,
      out => \@outlines,
      err => \@errlines,
    };
    TEST: while (my $next = shift @test_text) {
      my ($type, $payload) = $next->[1] =~ /^([<>!\$]) (.*)$/
        or die "Test line must start with <>!, got ${line}";
      if ($type eq '$') {
        unshift @test_text, $next;
        last TEST;
      }
      state %map = ('>' => 'in', '<' => 'out', '!' => 'err');
      push @{$t->{$map{$type}}}, $payload;
    }
    push @tests, $t;
  }


  foreach my $test (@tests) {
    my $src = join "\n", @{$test->{in}};
    diag "-> $src";
    if (my $out = eval { $evaluator->($src) }) {
      diag "<- $out";
      is
        $out,
        join("\n", @{$test->{out}}),
        "Data test ".$test->{idx}." output";
    } else {
      chomp(my $err = $@);
      diag "<- !$err";
      is
        $err,
        join("\n", @{$test->{err}}),
        "Data test ".$test->{idx}." error";
    }
  }
}
