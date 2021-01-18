package NXCL::01::Environment;

use NXCL::Class;
use NXCL::01::Runtime qw(run_til_done);
use vars qw(@EXPAND_TYPES);
use NXCL::01::TypeFunctions
  @EXPAND_TYPES = map "make_${_}", qw(
    Name Int String Combine List BlockProto Call
  );

lazy scope => sub { require NXCL::01::BaseScope; NXCL::01::BaseScope::scope };
lazy reader => sub { require NXCL::01::Reader; NXCL::01::Reader->new };
lazy makers => sub {
  +{
    map +($_ => __PACKAGE__->("make_${_}")), @EXPAND_TYPES
  }
};
lazy expander => sub ($self) {
  require NXCL::01::Expander;
  NXCL::01::Expander->new(makers => $self->makers);
};

sub eval_string ($self, $string) {
  my $parse = $self->reader->parse($string);
  my $tree = $self->expander->expand($parse);
  return run_til_done([ EVAL => $self->scope, $tree ], $NIL);
}

sub resume ($self, $value, $kstack) {
  return run_til_done(evaluate_to_value(undef, $value, undef, $kstack));
}

1;
