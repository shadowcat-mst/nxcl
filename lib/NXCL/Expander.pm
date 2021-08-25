package NXCL::Expander;

use NXCL::Class;

lazy maker => nxcl_require_and_call('NXCL::TypeMaker', can => 'make_value');

sub make ($self, @v) { $self->maker->(@v) }

sub expand ($self, $v) {
  my ($tok_type, @payload) = @$v; # later also $meta
  $self->${\"expand_${tok_type}"}(@payload);
}

sub expand_ws { () }
sub expand_comment { () }
sub expand_comma { () }
sub expand_semicolon { () }
sub expand_enter_list { () }
sub expand_leave_list { () }
sub expand_enter_call { () }
sub expand_leave_call { () }
sub expand_enter_block { () }
sub expand_leave_block { () }

sub expand_word ($self, $name) { $self->make(Name => $name) }

sub expand_symbol ($self, $name) { $self->make(Name => $name) }

sub expand_numeric ($self, $v) { $self->make(Numeric => $v) }

sub expand_qstring ($self, $v) {
  s/^'//, s/'$//, s/\\(['\\])/$1/g for $v;
  $self->make(String => $v)
}

sub expand_compound ($self, @v) {
  return $self->expand($v[0]) unless @v > 1;
  $self->make(Compound => map $self->expand($_), @v);
}

sub expand_list ($self, @v) {
  $self->make(List => map $self->expand($_), @v);
}

sub expand_block ($self, @v) {
  $self->make(BlockProto => $self->make(Call => map $self->expand($_), @v));
}

sub expand_call ($self, @v) {
  # handle the [x] case
  if (@v == 1 and @{$v[0][1]} == 1) { # guaranteed to be an expr node
    return $self->make(Call => [
      $self->make(Combine => $self->expand($v[0][1][0])),
    ]);
  }
  $self->make(Call => map $self->expand($_), @v);
}

sub expand_script ($self, @v) {
  $self->make(Call => map $self->expand($_), @v);
}

sub expand_expr ($self, @v) {
  # Must expand first so fluff like whitespace disappears before the '> 1'
  my @exp = map $self->expand($_), @v;
  return $exp[0] unless @exp > 1;
  $self->make(Combine => @exp);
}

1;
