package NXCL::Writer;

use NXCL::Utils qw(mset flatten raw uncons);
use NXCL::TypeRegistry qw(mset_name);
use NXCL::Class;

sub write ($self, $v) {
  my $mset_name = mset_name mset $v;
  if (my $writer = $self->can("_write_type_${mset_name}")) {
    return $self->$writer($v);
  }
  my $addr = '0x'.sprintf('%x', Scalar::Util::refaddr $v);
  return "${mset_name}.WAS('${addr}')";
}

sub _write_type_Int ($self, $v) { raw($v) }
sub _write_type_Name ($self, $v) { raw($v) }
sub _write_type_Numeric ($self, $v) { raw($v) }

sub _write_type_String ($self, $v) {
  # escaping required, but worry about this later
  "'".raw($v)."'";
}

sub _write_type_List ($self, $v) {
  '('.join(', ', map $self->write($_), flatten $v).')';
}

sub _write_type_Compound ($self, $v) {
  join('', map $self->_write_expr($_), flatten $v);
}

sub _write_type_Combine ($self, $v) {
  join(' ', map $self->_write_expr($_), flatten $v);
}

sub _write_type_Call ($self, $v) {
  '[ '.$self->_write_callseq(raw $v).' ]';
}

sub _write_type_Block ($self, $v) {
  '{ '.$self->_write_callseq(raw raw $v).' }'
}

sub _write_type_QQString ($self, $v) {
  # escaping required, but worry about this later
  my @parts = map {
    my $mset_name = mset_name mset $_;
    if ($mset_name eq 'String') {
      raw($_);
    } elsif ($mset_name eq 'Call' or $mset_name eq 'Block') {
      '$'.$self->${\"_write_type_${mset_name}"}($_)
    } else {
      die "Invalid QQString value of type ${mset_name}";
    }
  } flatten raw $v;
  '"'.join('', @parts).'"';
}

sub _write_callseq ($self, $v) {
  join('; ', map $self->write($_), flatten $v);
}

sub _write_expr ($self, $v) {
  my $mset_name = mset_name mset $v;
  if ($mset_name eq 'Combine') {
    return '[ '.$self->_write_type_Combine($v).' ]';
  }
  return $self->write($v);
}

1;
