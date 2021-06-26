package NXCL::RV;

use NXCL::WV;
use NXCL::Class;
use Autoload::AUTOCAN;

ro 'raw_value';
ro 'kstack';
ro 'env';

lazy value => sub ($self) {
  NXCL::WV->new(
    _raw_xcl_value => $self->raw_value,
    _xcl_environment => $self->env,
  );
};

sub AUTOCAN {
  my (undef, $method) = @_;
  return undef unless $method =~ s/^value_//;
  return sub ($self) { $self->value->$method };
}

1;
