package NXCL::TypeFunctions;

use Sub::Defer qw(defer_sub);
use NXCL::Package;

sub import ($class, @args) {
  my $targ = caller;
  foreach my $export (@args) {
    my ($type_name) = grep defined,
      $export =~ /^(?:[a-z_]+_(\w+)|(\w+?)(?:_Inst)?)$/;
    die "Can't parse ${export}" unless $type_name;
    # Only export if not already present
    unless ($targ->can($export)) {
      defer_sub "${targ}::${export}", sub {
        require NXCL::TypeRegistry;
        unless (eval { require "NXCL/${type_name}T.pm"; 1 }) {
          die "Error: Can't load ${export} for ${targ}:\n$@";
        }
        $NXCL::TypeRegistry::TypeInfo{$type_name}->export_for($export)
      };
    }
  }
}

1;
