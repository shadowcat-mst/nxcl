package NXCL::Expander;

use NXCL::Class;
use NXCL::Utils qw(with_meta);

lazy maker => load_and_call_cb('NXCL::TypeMaker', can => 'make_value');

sub _make ($self, @v) { $self->maker->(@v) }

sub expand ($self, $v) { $self->_expand($v) }

sub _expand ($self, $v) {
  my ($tok_type, $reader_meta, @payload) = @$v;
  map with_meta($_, { reader => $reader_meta }),
    $self->${\"_expand_${tok_type}"}(@payload);
}

sub _expand_ws { () }
sub _expand_comment { () }
sub _expand_comma { () }
sub _expand_semicolon { () }
sub _expand_enter_list { () }
sub _expand_leave_list { () }
sub _expand_enter_call { () }
sub _expand_leave_call { () }
sub _expand_enter_block { () }
sub _expand_leave_block { () }

sub _expand_word ($self, $name) { $self->_make(Name => $name) }

sub _expand_symbol ($self, $name) { $self->_make(Name => $name) }

sub _expand_numeric ($self, $v) { $self->_make(Numeric => $v) }

sub _expand_qstring ($self, $v) {
  s/^'//, s/'$//, s/\\(['\\])/$1/g for $v;
  $self->_make(String => $v)
}

sub _expand_compound ($self, @v) {
  return $self->_expand($v[0]) unless @v > 1;
  $self->_make(Compound => map $self->_expand($_), @v);
}

sub _expand_list ($self, @v) {
  $self->_make(List => map $self->_expand($_), @v);
}

sub _expand_block ($self, @v) {
  $self->_make(Block => $self->_make(Call => map $self->_expand($_), @v));
}

sub _expand_call ($self, @v) {
  # handle the [x] case
  if (@v == 1 and @{$v[0][1]} == 1) { # guaranteed to be an expr node
    return $self->_make(Call => [
      $self->_make(Combine => $self->_expand($v[0][1][0])),
    ]);
  }
  $self->_make(Call => map $self->_expand($_), @v);
}

sub _expand_script ($self, @v) {
  $self->_make(Call => map $self->_expand($_), @v);
}

sub _expand_expr ($self, @v) {
  # Must _expand first so fluff like whitespace disappears before the '> 1'
  my @exp = map $self->_expand($_), @v;
  return $exp[0] unless @exp > 1;
  $self->_make(Combine => @exp);
}

sub _expand_qqstring ($self, @v) {
  $self->_make(QQString => map $self->_expand($_), @v);
}

1;
