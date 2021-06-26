package NXCL::Environment;

use NXCL::Class;
use NXCL::Runtime qw(run_til_done);
use NXCL::TypeFunctions qw(make_List);
use NXCL::RV;

lazy scope => nxcl_require_and_call('NXCL::BaseScope', 'scope');

lazy reader => nxcl_require_and_call('NXCL::Reader', 'new');

lazy expander => nxcl_require_and_call('NXCL::Expander', 'new');

lazy weaver => nxcl_require_and_call('NXCL::Weaver', 'new');

sub _run ($self, $value, $kstack) {
  ($value, $kstack) = run_til_done($value, $kstack);
  return NXCL::RV->new(
    raw_value => $value,
    kstack => $kstack,
    env => $self
  );
}

sub eval_string ($self, $string) {
  my $parse = $self->reader->parse(script => $string);
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
