use NXCL::Test;
use NXCL::01::Environment;
use NXCL::01::TypeFunctions qw(
  make_Int make_String make_Native make_Combine make_List
);
use NXCL::01::JSON;
use JSON::Dumper::Compact qw(jdc);

my $env = NXCL::01::Environment->new;

my $func = make_Native(sub ($scope, $cmb, $args, $kstack) {
  return make_Int(raw((uncons($args))[0])+1);
});

foreach my $expect_ident (
  make_String("foo"),
  make_Int(4),
  $func,
  make_List(),
  make_List(make_Int(7)),
) {
  my ($ret) = $env->eval($expect_ident);
  is(nxcl2json($ret), nxcl2json($expect_ident));
}

done_testing;
