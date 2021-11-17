use NXCL::Test;
use Capture::Tiny qw(capture_stdout);
use Text::Diff;

my $file = $0 =~ s/\.t$/.transcript/r;

my $result = capture_stdout {
  system(perl => 'dev/ts' => $file)
};

if (@ARGV and $ARGV[0] eq '--rewrite') {
  open my $fh, '>', $file or die "Couldn't open ${file} for writing: $!";
  print $fh $result;
  close $fh;
  exit 0;
}

my $diff = diff 't/quicktest.transcript', \$result;

is $diff, '', 'No diffs';

done_testing;
