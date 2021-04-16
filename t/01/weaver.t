use NXCL::Test;
use NXCL::01::Utils qw(uncons raw);
use NXCL::01::Weaver;
use NXCL::01::JSON;
use JSON::Dumper::Compact jdc => { max_width => 76 };
use NXCL::01::ValueBuilders;

my $weaver = NXCL::01::Weaver->new;

sub wv ($code, $val, $msg = undef) {
  my ($ret) = $weaver->weave($val);
  @_ = (nxcl2json($ret), nxcl2json($val), $msg, jdc(nxcl2json($ret)));
  goto &is;
}

wv(
  Cmb(I 3, N '+', I 4),
  Cmb(N '+', I 3, I 4),
  'Combine 3 + 4 => [ + 3 4 ]',
);

wv(
  Cmp(I 3, N '+', I 4),
  Cmb(N '+', I 3, I 4),
  'Compound 3+4 => [ + 3 4 ]',
);

wv(
  Cmb(I 3, N '+', I 4, N '--', I 7),
  Cmb(N '==', Cmb(N '+', I 3, I 4), I 7),
  'Combine 3 + 4 == 7 => [ = [ + 3 4 ] 7 ]',
);

wv(
  Cmp(N 'x', N '.', N 'y'),
  Cmb(N '.', N 'x', N 'y'),
  'x.y => [ . x y ]',
);

done_testing;
