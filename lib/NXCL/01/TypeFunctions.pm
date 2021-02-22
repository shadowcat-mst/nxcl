package NXCL::01::TypeFunctions;

use NXCL::01::TypeInfo;
use Sub::Defer qw(defer_sub);
use NXCL::Package;

my $type_info = NXCL::01::TypeInfo->registry;

sub import ($class, @args) {
  my $targ = caller;
  foreach my $export (@args) {
    my ($type_name) = grep defined, $export =~ /^(?:\w+_(\w+)|(\w+)_Inst)$/;
    die "Can't parse ${export}" unless $type_name;
    defer_sub "${targ}::${export}", sub {
      require "NXCL/01/${type_name}T";
      $type_info->{$type_name}->export_for($export)
    };
  }
}

1;
