package NXCL::01::Environment;

use NXCL::Class;
use NXCL::01::Runtime qw(run_til_done);
use vars qw(@EXPAND_TYPES);
use NXCL::01::TypeFunctions
  map "make_${_}", @EXPAND_TYPES = qw(
    Name Int String Combine List BlockProto Call
  );

lazy scope => sub {
   require NXCL::01::BaseScope; NXCL::01::BaseScope::scope()
};
lazy reader => sub {
  require NXCL::01::Reader; NXCL::01::Reader->new
};
lazy makers => sub {
  +{
    map +($_ => __PACKAGE__->can("make_${_}")), @EXPAND_TYPES
  }
};
lazy expander => sub ($self) {
  require NXCL::01::Expander;
  NXCL::01::Expander->new(makers => $self->makers);
};

sub _run ($self, $value, $kstack) {
  @{ run_til_done($value, $kstack) };
}

sub eval_string ($self, $string) {
  my $parse = $self->reader->from_string($string);
  my $script = $self->expander->expand($parse);
  $self->_run([ EVAL => $self->scope, $script ], make_List([ 'HOST' ]));
}

sub resume ($self, $value, $kstack) {
  $self->_run([ JUST => $value ], $kstack);
}

1;
