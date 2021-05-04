use NXCL::Test;
use NXCL::Utils qw(uncons raw);
use NXCL::Environment;
use NXCL::JSON;
use NXCL::TypeFunctions qw(make_Native);
use JSON::Dumper::Compact jdc => { max_width => 76 };
use NXCL::ValueBuilders;

my $env = NXCL::Environment->new;

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
  return ([ JUST => I(raw((uncons($args))[0])+1) ], $kstack);
});

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
