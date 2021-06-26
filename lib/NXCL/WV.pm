package NXCL::WV;

use NXCL::Class;
use NXCL::ValueBuilders;
use Autoload::AUTOCAN;

ro '_raw_xcl_value';
ro '_xcl_environment';

sub _call_method ($self, $method) {
  my $mcall = Cmb( Call($method, $self->_raw_xcl_value) );
  $self->_xcl_environment->eval($mcall);
}

sub AUTOCAN {
  my (undef, $method) = @_;
  # this signature means no arguments, this is fine temporarily
  return sub ($self) { $self->_call_method($method) };
}

1;
