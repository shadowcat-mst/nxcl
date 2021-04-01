use NXCL::Test;
use NXCL::01::Utils qw(uncons raw);
use NXCL::01::Environment;
use NXCL::01::TypeFunctions qw(
  make_Int make_String make_Native make_Combine make_List make_Name
  make_Curry
);
use NXCL::01::JSON;
use JSON::Dumper::Compact jdc => { max_width => 76 };

my $env = NXCL::01::Environment->new;

sub Dv ($tag, $v) {
  warn "$tag: ".jdc(nxcl2json($v));
  return $v;
}

sub Ev($tag, $v) {
  my ($ret) = $env->eval($v);
  return Dv($tag, $ret);
}

sub isv ($code, $val, $msg = undef) {
  my ($ret) = $env->eval($code);
  @_ = (nxcl2json($ret), nxcl2json($val), $msg, jdc(nxcl2json($ret)));
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

isv(Cmb( Cmb( Cmb( N"dot", N"minus" ) ), I 7, I 3), I 4);

done_testing;
