use NXCL::Test;
use NXCL::01::Environment;
use NXCL::01::TypeFunctions qw(make_Int make_String);
use NXCL::01::JSON;
use JSON::Dumper::Compact qw(jdc);

my $env = NXCL::01::Environment->new;

foreach my $expect_ident (
  make_String("foo"),
  make_Int(4),
) {
  my ($ret) = $env->eval($expect_ident);
  is(nxcl2json($ret), nxcl2json($expect_ident));
}

done_testing;
