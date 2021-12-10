package NXCL::TypeSyntax;

use NXCL::TypeInfo;
use NXCL::Package;
use NXCL::OpUtils;
use Keyword::Declare;
use curry;

sub import {
  my $targ = caller;
  my ($name) = $targ =~ m/^NXCL::(\w+)T$/
    or die "Couldn't extract type name from target package ${targ}";
  my $type_info = \%NXCL::TypeRegistry::TypeInfo;
  die "Double import of ".__PACKAGE__." into ${targ}" if $type_info->{$name};
  NXCL::Package->import::into(1);
  NXCL::OpUtils->import::into(1);
  my $info = $type_info->{$name}
    = NXCL::TypeInfo->new(package => $targ, name => $name);
  {
    no strict 'refs';
    *{"${targ}::_make"} = $info->curry::make;
    *{"${targ}::Type_Info"} = \$info;
  }
  keyword export (Ident $name, List $args, Block $body) {
    return qq{
      sub $name $args $body
      \$Type_Info->add_export("$name", \\\&${name});
    };
  }
  keyword static (Ident $name, Block $body) {
    return qq{
      \$Type_Info->add_static_apv($name => sub (\$self, \$args) $body);
    };
  }
  keyword method (Ident $name, Block $body) {
    return qq{
      \$Type_Info->add_method_apv($name => sub (\$self, \$args) $body);
    };
  }
}

1;
