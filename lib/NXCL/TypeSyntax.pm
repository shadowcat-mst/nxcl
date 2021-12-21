package NXCL::TypeSyntax;

use NXCL::TypeInfo;
use NXCL::Package;
use NXCL::OpUtils;
use Keyword::Declare;
use curry;

# use Keyword::Declare;
# ...
# keyword export (Ident $name, List $args, Block $body) {
#   return qq{
#     sub $name $args $body
#     \$Type_Info->add_export("$name", \\\&${name});
#   };
# }
# keyword static (Ident $name, Block $body) {
#   return qq{
#     \$Type_Info->add_static_apv($name => sub (\$self, \$args) $body);
#   };
# }
# keyword staticx (Ident $name, Block $body) {
#   return qq{
#     \$Type_Info->add_static_opv($name => sub (\$self, \$args) $body);
#   };
# }
# keyword staticn (Ident $name, Block $body) {
#   return qq{
#     \$Type_Info->add_static_opv($name => sub (\$self, \$) $body);
#   };
# }
# keyword method (Ident $name, Block $body) {
#   return qq{
#     \$Type_Info->add_method_apv($name => sub (\$self, \$args) $body);
#   };
# }
# keyword methodx (Ident $name, Block $body) {
#   return qq{
#     \$Type_Info->add_method_opv($name => sub (\$self, \$args) $body);
#   };
# }
# keyword methodn (Ident $name, Block $body) {
#   return qq{
#     \$Type_Info->add_method_opv($name => sub (\$self, \$) $body);
#   };
# }

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
  my $S = ' ';
  Keyword::Simple::define export => sub {
    ${$_[0]} =~ s{
      \s* (\w+)
    }{
      \$Type_Info->add_export("$1", \\\&$1);
      sub $1$S
    }x;
  };
  foreach my $kwset ([ static => 'Type_' ], [ method => 'Inst_' ]) {
    my ($base, $prefix) = @$kwset;
    Keyword::Simple::define $base => sub {
      ${$_[0]} =~ s{
        \s* (\w+)
      }{
        \$Type_Info->add_${base}_apv("$1", \\\&${prefix}$1);
        sub ${prefix}$1 (\$self, \$args)$S
      }x;
    };
    Keyword::Simple::define "${base}x" => sub {
      ${$_[0]} =~ s{
        \s* (\w+)
      }{
        \$Type_Info->add_${base}_opv("$1", \\\&${prefix}$1);
        sub ${prefix}$1 (\$self, \$args)$S
      }x;
    };
    Keyword::Simple::define "${base}n" => sub {
      ${$_[0]} =~ s{
        \s* (\w+)
      }{
        \$Type_Info->add_${base}_opv("$1", \\\&${prefix}$1);
        sub ${prefix}$1 (\$self, \$)$S
      }x;
    };
  }
}

1;
