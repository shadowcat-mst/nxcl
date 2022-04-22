package NXCL::Writer;

use NXCL::Utils qw(mset flatten raw uncons);
use NXCL::TypeRegistry qw(mset_name);
use NXCL::Class;

sub write ($self, $v) {
  my $mset_name = mset_name mset $v;
  if (my $writer = $self->can("_write_type_${mset_name}")) {
    return $self->$writer($v);
  }
  die "No writer for ${mset_name}";
}

sub _write_type_Name ($self, $v) { raw($v) }
sub _write_type_Numeric ($self, $v) { raw($v) }

sub _write_type_String ($self, $v) {
  # this is wrong
  "'".raw($v)."'";
}

sub _write_type_List ($self, $v) {
  '('.join(', ', map $self->write($_), flatten $v).')';
}

sub _write_type_Compound ($self, $v) {
  join('', map $self->write($_), flatten $v);
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
