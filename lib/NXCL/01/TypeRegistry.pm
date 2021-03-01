package NXCL::01::TypeRegistry;

use NXCL::Package;
use Scalar::Util qw(weaken);

our %Registry;

require NXCL::01::OpDictT;
require NXCL::01::NativeT;

my @bs = my ($opdict_info, $native_info) = @Registry{'OpDict', 'Native'};

$_->{inst_mset} = [] for @bs;

foreach my $bs (@bs) {
  my $inst_mset = $bs->_build_inst_mset;
  @{$bs->{inst_mset}} = @$inst_mset;
}

weaken($opdict_info->inst_mset->[0]);

weaken($_->[0]) for values %{$native_info->inst_mset->[1][1]};

1;

sub registry { \%Registry }
