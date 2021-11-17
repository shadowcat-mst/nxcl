use NXCL::Test;
use Capture::Tiny qw(capture_stdout);
use Text::Diff;

my $result = capture_stdout {
  system(perl => 'dev/ts' => 't/quicktest.transcript')
};

my $diff = diff \$result, 't/quicktest.transcript';

is $diff, '', 'No diffs';

done_testing;
