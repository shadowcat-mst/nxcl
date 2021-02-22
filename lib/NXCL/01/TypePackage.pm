package NXCL::01::TypePackage;

use NXCL::01::TypeInfo;
use NXCL::Package;
use curry;

my $type_info = NXCL::01::TypeInfo->registry;

sub import {
  NXCL::Package->import;
  my $targ = caller;
  my ($name) = $targ = m/^NXCL::01::(\w+)T$/
    or die "Couldn't extract type name from target package ${targ}";
  die "Double import of ".__PACKAGE__." into ${targ}" if $type_info->{$name};
  my $info = $type_info->{$name}
    = NXCL::01::TypeInfo->new(package => $targ, name => $name);
  no strict 'refs';
  *{"${targ}::_make"} = $info->curry::make;
  *{"${targ}::export"} = $info->curry::add_export;
  *{"${targ}::method"} = $info->curry::add_method;
  *{"${targ}::static"} = $info->curry::add_static;
  *{"${targ}::wrap"} = $info->curry::mark_wrapped;
}

1;
