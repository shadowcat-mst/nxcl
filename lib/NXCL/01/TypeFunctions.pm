package NXCL::01::TypeFunctions;

use Sub::Defer qw(defer_sub);
use Import::Into;
use NXCL::Package;

our %Have_Imported;

sub import ($class, @args) {
  my $targ = caller;
  foreach my $export (@args) {
    my ($type) = grep defined, $export =~ /^(?:\w+_(\w+)|(\w+)T)$/;
    die "Can't parse ${export}" unless $type;
    defer_sub "${targ}::${export}", sub {
      $Have_Imported{$type} ||= do {
        require NXCL::01::Types;
        NXCL::01::Types->import($type);
        1;
      };
      $class->can($export)
        or die "Didn't receive export ${export} from type ${type}";
    };
  }
}

1;
