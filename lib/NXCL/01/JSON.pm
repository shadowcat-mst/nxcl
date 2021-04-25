package NXCL::01::JSON;

use JSON::PP ();
use NXCL::01::Utils qw(mset rtype raw uncons flatten);
use NXCL::01::TypeRegistry;
use NXCL::01::TypeFunctions qw(List_Inst);
use NXCL::01::ReprTypes;
use Sub::Util qw(subname);
use NXCL::Exporter;

our @EXPORT = qw(nxcl2json json2nxcl);

sub json2nxcl { die "NYI" }

sub nxcl2json ($v) {
  return undef unless defined $v;
  my $mset_name = mset_name mset $v;
  my $rtype = rtype($v);
  my $type = "${mset_name} (${$rtype})";
  return [ $type ] if $rtype == NilR;
  return [ "${mset_name} (flattened)", map nxcl2json($_), flatten($v) ]
    if mset($v) == List_Inst
      or ($rtype == ConsR and List_Inst == mset +(uncons $v)[1]);
  return [ $type, map nxcl2json($_), uncons($v) ]
    if $rtype == ConsR;
  my $rval = repr2json($rtype, raw($v));
  return [ $type, $rval ];
}

sub repr2json ($t, $r) {
  return $r ? JSON::PP->true : JSON::PP->false if $t == BoolR;
  return $r if $t == CharsR or $t == BytesR or $t == IntR;
  return nxcl2json($r) if $t == ValR or $t == VarR;
  return +{ map +($_ => nxcl2json($r->{$_})), sort keys %$r } if $t == DictR;
  return subname(\&$r) if $t == NativeR;
  die "Unserializable repr type $t";
}

1;
