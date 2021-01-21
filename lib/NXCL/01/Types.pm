package NXCL::01::Types;

use strict;
use warnings;
use experimental 'signatures';
use Scalar::Util qw(weaken);
use NXCL::01::TypeExporter ();
use NXCL::01::Utils qw(make_string_combiner panic mkv);
use NXCL::01::ReprTypes qw(DictR);

sub import ($, @args) {
  my $caller = caller;
  foreach my $type_name (@args) {
    export_type_into($caller, load_type($type_name));
  }
  return
}

our %Types;

sub OpDictT { $Types{OpDict} }

sub load_type ($name) {
  return $Types{$name} //= do {
    _load_type($name);
  }
}

sub _load_type ($name) {
  my $type_file = "NXCL/01/${name}T.pm";
  require $type_file;
  my $pkg = "NXCL::01::${name}T";
  my $type_info = $NXCL::01::TypeExporter::Type_Info{$pkg};
  return make_type_object($name => $type_info);
}

sub _method_dict ($src) {
  my %real;
  foreach $name (keys %$src) {
    my $info = $src->{$name};
    my $orig_code = $info->[0];
    my $code = sub ($scope, $cmb, $args, $kstack) {
      # should test type of first of $args
      $orig_code->($scope, $cmb, uncons($args), $kstack);
    };
    my $native = make_Native($code);
    $real{$name} = $info->[1]{wrap}
      ? make_ApMeth($native)
      : $native;
  }
  reture \%real;
}

sub make_type_object ($name, $info) {
  my $meta_type_hr = _method_dict($info->{static});
  my $type_hr = _method_dict($info->{method});
  my $meta_type = make_OpDict($meta_type_hr);
  my $type = mkv($meta_type, DictR ,=> $type_hr);
  return $type;
}

sub export_type_into ($into, $type_name) {
  my %exports = %{$NXCL::01::TypeExporter{$type_name}{export}};
  foreach my $name (sort keys %exports) {
    no strict 'refs';
    *{"${into}::${name}"} = $exports{$name};
  }
}

for my $type (load_type('OpDict')) {
  weaken(my $weak = $type);
  $type->[0] = $weak;
}

1;
