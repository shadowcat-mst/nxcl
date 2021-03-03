package NXCL::01::TypeRegistry;

use Scalar::Util qw(weaken);
use NXCL::Exporter;

our @EXPORT = qw(%TypeInfo %Mset);

our %TypeInfo;
our %Mset;

unless (our $Loading) {
  local $Loading = 1;

  require NXCL::01::OpDictT;
  require NXCL::01::NativeT;

  my @bs = my ($opdict_info, $native_info) = @TypeInfo{'OpDict', 'Native'};

  $_->{inst_mset} = [] for @bs;

  foreach my $bs (@bs) {
    my $inst_mset = do {
      local %Mset; # ignore changes here from build
      $bs->_build_inst_mset;
    };
    @{$bs->{inst_mset}} = @$inst_mset;
    $Mset{$bs->inst_mset} = join('_', $bs->name, 'Inst');
  }

  weaken($opdict_info->inst_mset->[0]);

  weaken($_->[0]) for values %{$native_info->inst_mset->[1][1]};
}

1;
