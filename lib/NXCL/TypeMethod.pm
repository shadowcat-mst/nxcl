package NXCL::TypeMethod;

use NXCL::Utils qw(uncons);
use Sub::Util ();
use NXCL::Class;
use overload '&{}' => 'as_method', fallback => 1;

ro 'code';

sub as_method ($self, @) {
  my $code = $self->code;
  Sub::Util::set_subname $self->subname, sub ($scope, $cmb, $args, $kstack) {
    ($code->($scope, $cmb, uncons($args)), $kstack);
  }
}

sub subname ($self) {
  return 'Method_'.Sub::Util::subname($self->code);
}

1;
