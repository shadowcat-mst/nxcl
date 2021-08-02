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

sub _run ($self, $scope, $value, $kstack) {
  ($scope, $value, $kstack) = run_til_done($scope, $value, $kstack);
  return NXCL::RV->new(
    raw_value => $value,
    kstack => $kstack,
    scope => $scope,
    env => $self
  );
}

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
  $self->_run($scope, EVAL($value), make_List(HOST()));
}

sub eval ($self, $value) {
  $self->eval_in($self->scope, $value);
}

sub resume ($self, $value, $kstack) {
  $self->_run($self->scope, JUST($value), $kstack);
}

1;
