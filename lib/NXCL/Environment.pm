package NXCL::Environment;

use NXCL::Class;
use NXCL::Runtime qw(run_til_done);
use NXCL::TypeFunctions qw(make_List);
use NXCL::OpUtils;
use NXCL::RV;

lazy scope => nxcl_require_and_call('NXCL::BaseScope', 'scope');

lazy reader => nxcl_require_and_call('NXCL::Reader', 'new');

lazy expander => nxcl_require_and_call('NXCL::Expander', 'new');

lazy weaver => nxcl_require_and_call('NXCL::Weaver', 'new');

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
  (undef, $value) = run_til_done(
    $scope, EVAL($value), make_List(HOST())
  );
  return NXCL::RV->new(
    xcl_value => $value,
    xcl_environment => $self
  );
}

sub eval ($self, $value) {
  $self->eval_in($self->scope, $value);
}

1;
