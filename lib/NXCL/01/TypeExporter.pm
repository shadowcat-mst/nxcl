package NXCL::01::TypeExporter;

use strict;
use warnings;
use experimental 'signatures';
use Exporter ();
use Sub::Util qw(set_subname);

our %Type_Info;

our @EXPORT = qw(wrap method static);

our @EXPORT_OK = (@EXPORT, qw());

sub import {
  strict->import::into(1);
  warnings->import::into(1);
  feature->import::into(1, ':5.16');
  experimental->import::into(1, 'signatures');
  warnings->import::into(1, FATAL => 'uninitialized');
  NXCL::01::Utils->import::into(1, qw(evaluate_to_value));
  $Type_Info{+caller} ||= {};
  goto &Exporter::import;
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
