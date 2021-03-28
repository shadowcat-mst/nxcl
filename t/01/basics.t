use NXCL::Test;
use NXCL::01::Utils qw(uncons raw);
use NXCL::01::Environment;
use NXCL::01::TypeFunctions qw(
  make_Int make_String make_Native make_Combine make_List make_Name
);
use NXCL::01::JSON;
use JSON::Dumper::Compact qw(jdc);

my $env = NXCL::01::Environment->new;

sub isv ($code, $val, @rest) {
  my ($ret) = $env->eval($code);
  @_ = (nxcl2json($ret), nxcl2json($val), @rest);
  goto &is;
}

my $func = make_Native(sub ($scope, $cmb, $args, $kstack) {
  return ([ JUST => make_Int(raw((uncons($args))[0])+1) ], $kstack);
});

foreach my $expect_ident (
  make_String("foo"),
  make_Int(4),
  $func,
  make_List(),
  make_List(make_Int(7)),
) {
  isv($expect_ident, $expect_ident);
}

isv(make_Combine($func, make_List(make_Int 2)), make_Int(3));

use NXCL::01::ValueBuilders;

isv(
  Cmb( Cmb( N"dot", I(7), N"minus" ), I(3) ),
  I(4)
);

done_testing;
