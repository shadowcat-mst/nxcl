package NXCL::Environment;

use NXCL::Class;
use NXCL::Runtime qw(run_til_done);
use vars qw(@EXPAND_TYPES);
use NXCL::TypeFunctions
  map "make_${_}", @EXPAND_TYPES = qw(
    Name Int String Combine List BlockProto Call Compound
  );

lazy scope => nxcl_require_and_call('NXCL::BaseScope', 'scope');

lazy reader => nxcl_require_and_call('NXCL::Reader', 'new');

lazy makers => sub {
  +{
    map +($_ => __PACKAGE__->can("make_${_}")), @EXPAND_TYPES
  }
};

lazy expander => sub ($self) {
  nxcl_require('NXCL::Expander')->new(makers => $self->makers);
};

lazy weaver => nxcl_require_and_call('NXCL::Weaver', 'new');

sub _run ($self, $value, $kstack) {
  @{ run_til_done($value, $kstack) };
}

sub eval_string ($self, $string) {
  my $parse = $self->reader->from_string($string);
  my $exp = $self->expander->expand($parse);
  my $script = $self->weaver->weave($exp);
  $self->eval($script);
}

sub eval ($self, $value) {
  $self->_run([ EVAL => $self->scope, $value ], make_List([ 'HOST' ]));
}

sub resume ($self, $value, $kstack) {
  $self->_run([ JUST => $value ], $kstack);
}

1;
