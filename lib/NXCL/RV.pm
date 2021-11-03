package NXCL::RV;

use NXCL::Class;
use NXCL::ValueBuilders;
use Autoload::AUTOCAN;

ro 'raw_value';
ro 'env';

sub AUTOCAN {
  my (undef, $method) = @_;
  return undef unless $method =~ s/^value_//;
  return sub ($self) {
    my $mcall = Cmb( Call($method, $self->raw_value) );
    $self->env->eval($mcall)
  };
}

1;
