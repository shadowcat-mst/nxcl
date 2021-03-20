use NXCL::Test;
use NXCL::01::Utils qw(uncons raw);
use NXCL::01::Environment;
use NXCL::01::TypeFunctions qw(
  make_Int make_String make_Native make_Combine make_List make_Name
);
use NXCL::01::JSON;
use JSON::Dumper::Compact qw(jdc);

sub isv ($l, $r, @rest) {
  @_ = (nxcl2json($l), nxcl2json($r), @rest);
  goto &is;
}

my $env = NXCL::01::Environment->new;

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
  my ($ret) = $env->eval($expect_ident);
  isv($ret, $expect_ident);
}

{

  my ($ret) = $env->eval(make_Combine($func, make_List(make_Int 2)));

  isv($ret, make_Int(3));
}

use NXCL::01::ValueBuilders;

{
  my ($ret) = $env->eval(
    Cmb( Cmb( N"dot", I(7), N"minus" ), I(3) )
  );
  isv($ret, I(4));
}

done_testing;
