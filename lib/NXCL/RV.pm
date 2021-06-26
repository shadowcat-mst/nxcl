package NXCL::RV;

use NXCL::WV;
use NXCL::Class;

ro 'raw_value';
ro 'kstack';
ro 'env';

lazy value => sub ($self) {
  NXCL::WV->new(
    _raw_xcl_value => $self->raw_value,
    _xcl_environment => $self->env,
  );
};

1;
