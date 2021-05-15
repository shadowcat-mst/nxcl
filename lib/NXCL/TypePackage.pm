package NXCL::TypePackage;

use NXCL::TypeInfo;
use NXCL::Package;
use curry;

sub import {
  NXCL::Package->import;
  my $targ = caller;
  my ($name) = $targ =~ m/^NXCL::(\w+)T$/
    or die "Couldn't extract type name from target package ${targ}";
  my $type_info = \%NXCL::TypeRegistry::TypeInfo;
  die "Double import of ".__PACKAGE__." into ${targ}" if $type_info->{$name};
  my $info = $type_info->{$name}
    = NXCL::TypeInfo->new(package => $targ, name => $name);
  no strict 'refs';
  *{"${targ}::_make"} = $info->curry::make;
  *{"${targ}::export"} = $info->curry::add_export;
  *{"${targ}::method"} = $info->curry::add_method;
  *{"${targ}::static"} = $info->curry::add_static;
  *{"${targ}::wrap"} = $info->curry::mark_wrapped;
  *{"${targ}::JUST"} = sub ($v) { [ JUST => $v ] };
}

1;
