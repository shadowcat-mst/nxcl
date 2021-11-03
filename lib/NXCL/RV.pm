package NXCL::RV;

use NXCL::Class;
use NXCL::ValueBuilders;
use NXCL::Utils qw(raw);
use Autoload::AUTOCAN;

ro 'xcl_value';
ro 'xcl_environment';

sub xcl_raw_value { raw($_[0]->xcl_value) }

sub AUTOCAN {
  my (undef, $method) = @_;
  return undef unless $method =~ s/^value_//;
  return sub ($self) {
    my $mcall = Cmb( Call($method, $self->xcl_value) );
    $self->xcl_environment->eval($mcall)
  };
}

1;
