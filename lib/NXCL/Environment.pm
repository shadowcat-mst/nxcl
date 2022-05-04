package NXCL::Environment;

use NXCL::Class;
use NXCL::TypeFunctions qw(make_List);
use NXCL::OpUtils;
use NXCL::RV;

lazy scope => load_and_call_cb('NXCL::BaseScope', 'scope');

lazy reader => load_and_call_cb('NXCL::Reader', 'new');

lazy expander => load_and_call_cb('NXCL::Expander', 'new');

lazy weaver => load_and_call_cb('NXCL::Weaver', 'new');

lazy trace_cb => sub { our $DEFAULT_TRACE_CB };

lazy strand => load_and_call_cb('NXCL::Strand', 'new');

sub eval_string ($self, $string) {
  $self->eval_string_in($self->scope, $string);
}

sub eval_string_in ($self, $scope, $string) {
  my $parse = $self->reader->parse(script => $string);
  my $exp = $self->expander->expand($parse);
  my $script = $self->weaver->weave($exp);
  $self->eval_in($scope, $script);
}

sub eval_in ($self, $scope, $value) {
  my (undef, $return_value) = $self->strand->run_til_host(
    [ [ [ make_List($value) ], {}, $scope, 0, [], {} ] ],
    [ HOST('value'), EVAL($value) ],
    $self->trace_cb,
  );
  return NXCL::RV->new(
    xcl_value => $return_value,
    xcl_environment => $self
  );
}

sub eval ($self, $value) {
  $self->eval_in($self->scope, $value);
}

1;
