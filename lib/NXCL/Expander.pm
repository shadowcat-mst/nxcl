package NXCL::Expander;

use NXCL::Class;

ro 'makers';

sub expand ($self, $v) {
  my ($tok_type, $payload) = @$v; # later also $meta
  $self->${\"expand_${tok_type}"}($payload);
}

sub make ($self, $type, @v) {
  ($self->makers->{$type}||die"No maker for ${type}")->(@v);
}

sub expand_word ($self, $name) {
  $self->make(Name => $name);
}

sub expand_symbol ($self, $name) {
  $self->make(Name => $name);
}

sub expand_uint ($self, $v) {
  $self->make(Int => 0+$v);
}

sub expand_string ($self, $v) {
  $self->make(String => $v);
}

sub expand_compound ($self, $v) {
  return $self->expand($v->[0]) unless @$v > 1;
  $self->make(Compound => map $self->expand($_), @$v);
}

sub expand_list ($self, $v) {
  $self->make(List => map $self->expand($_), @$v);
}

sub expand_block ($self, $v) {
  $self->make(BlockProto => map $self->expand($_), @$v);
}

sub expand_call ($self, $v) {
  # handle the [x] case
  if (@$v == 1 and @{$v->[0][1]} == 1) { # guaranteed to be an expr node
    return $self->make(Call => [
      $self->make(Combine => $self->expand($v->[0][1][0])),
    ]);
  }
  $self->make(Call => map $self->expand($_), @$v);
}

sub expand_script ($self, $v) {
  $self->make(Call => map $self->expand($_), @$v);
}

sub expand_expr ($self, $v) {
  return $self->expand($v->[0]) unless @$v > 1;
  my ($firstp, @restp) = @$v;
  $self->make(Combine =>
    $self->expand($firstp),
    map $self->expand($_), @restp
  );
}

1;
