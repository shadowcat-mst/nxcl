package NXCL::01::TypeExporter;

use NXCL::Package;

sub import {
  NXCL::Package->import;
  goto &Exporter::import;
}

our %Type_Info;

our @EXPORT = qw(wrap method static export _make);

sub _make {
  my $targ = caller;
  die unless my $type = $Type_Info{$targ}{type};
  require NXCL::01::Utils;
  NXCL::01::Utils::mkv($type, @_);
}

sub export ($name, $code) {
  my $targ = caller;
  $Type_Info{$targ}{exports}{$name} = [ $code ];
}

sub method ($name, $code) {
  my $targ = caller;
  $Type_Info{$targ}{methods}{$name} = [ $code ];
}

sub static ($name, $code) {
  my $targ = caller;
  $Type_Info{$targ}{statics}{$name} = [ $code ];
}

sub wrap ($info) { $info->[1]{wrap} = 1 }

1;
