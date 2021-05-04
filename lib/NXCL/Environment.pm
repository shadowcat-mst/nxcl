package NXCL::Environment;

use NXCL::Class;
use NXCL::Runtime qw(run_til_done);
use vars qw(@EXPAND_TYPES);
use NXCL::TypeFunctions
  map "make_${_}", @EXPAND_TYPES = qw(
    Name Int String Combine List BlockProto Call Compound
  );

lazy scope => sub {
   require NXCL::BaseScope; NXCL::BaseScope::scope()
};

lazy reader => sub {
  require NXCL::Reader; NXCL::Reader->new
};

lazy makers => sub {
  +{
    map +($_ => __PACKAGE__->can("make_${_}")), @EXPAND_TYPES
  }
};

lazy expander => sub ($self) {
  require NXCL::Expander;
  NXCL::Expander->new(makers => $self->makers);
};

sub _run ($self, $value, $kstack) {
  @{ run_til_done($value, $kstack) };
}

sub eval_string ($self, $string) {
  my $parse = $self->reader->from_string($string);
  my $script = $self->expander->expand($parse);
  $self->eval($script);
}

sub eval ($self, $value) {
  $self->_run([ EVAL => $self->scope, $value ], make_List([ 'HOST' ]));
}

sub resume ($self, $value, $kstack) {
  $self->_run([ JUST => $value ], $kstack);
}

1;
