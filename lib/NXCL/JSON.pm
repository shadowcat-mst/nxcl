package NXCL::JSON;

use JSON::PP ();
use NXCL::Utils qw(mset object_is rtype raw uncons flatten);
use NXCL::TypeRegistry;
use NXCL::TypeFunctions qw(List_Inst);
use NXCL::ReprTypes;
use Sub::Util qw(subname);
use NXCL::Exporter;
use warnings FATAL => 'recursion';

our @EXPORT = qw(nxcl2json json2nxcl);

sub json2nxcl { die "NYI" }

sub nxcl2json ($v) {
  return undef unless defined $v;
  my $mset_name = mset_name mset $v;
  my $rtype = rtype($v);
  return [ "${mset_name} (UNDEF)" ] unless defined($rtype);
  return [ "${mset_name} (CORRUPT ${rtype})" ]
    unless ref($rtype) =~ /^NXCL::_::RType::/;
  my $type = "${mset_name} (${$rtype})";
  return [ $type ] if $rtype == NilR;
  return [ "${mset_name} (flattened)", map nxcl2json($_), flatten($v) ]
    if object_is($v, List_Inst)
      or ($rtype == ConsR and object_is +(uncons $v)[1], List_Inst);
  return [ $type, map nxcl2json($_), uncons($v) ]
    if $rtype == ConsR;
  return [ $type, do {
    my %h = %{raw($v)};
    +(map {
      +{ $_ => nxcl2json($h{$_}) }
    } sort keys %h );
  } ] if $rtype == DictR;
  my $rval = repr2json($rtype, raw($v));
  return [ join ' ', $type, $rval ] unless ref $rval;
  return [ $type, $rval ];
}

sub repr2json ($t, $r) {
  return $r ? JSON::PP->true : JSON::PP->false if $t == BoolR;
  return $r if $t == CharsR or $t == BytesR or $t == IntR;
  return nxcl2json($r) if $t == ValR or $t == VarR;
  return +{ map +($_ => nxcl2json($r->{$_})), sort keys %$r } if $t == DictR;
  return (eval { subname(\&$r) } // "$r") if $t == NativeR;
  die "Unserializable repr type $t";
}

1;
