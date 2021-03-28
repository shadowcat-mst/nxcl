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

use NXCL::01::ValueBuilders;

foreach my $ident (
  S"foo",
  I 4,
  $func,
  L(),
  L(I 7),
) {
  isv($ident, $ident);
}

isv(Cmb($func, I 2), I 3);

isv(Cmb( Cmb( N"dot", I 7, N"minus" ), I 3 ), I 4);

done_testing;
