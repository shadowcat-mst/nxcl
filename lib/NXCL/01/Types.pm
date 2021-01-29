package NXCL::01::Types;

use Scalar::Util qw(weaken);
use NXCL::01::TypeExporter ();
use NXCL::01::Utils qw(panic mkv);
use NXCL::01::ReprTypes qw(DictR);
use NXCL::01::TypeFunctions qw(make_OpDict make_ApMeth make_Native);
use NXCL::Package;

sub import ($, @args) {
  my $caller = caller;
  foreach my $type_name (@args) {
    load_type($type_name);
    export_type_into($caller, $type_name);
  }
  no warnings 'redefine';
  no strict 'refs';
  *{"${caller}::type_object"} = \&type_object;
  *{"${caller}::type_name_of"} = \&type_name_of;
}

our %Types;

sub type_object ($name) { $Types{$name} }

sub type_name_of ($type) { +{ reverse %Types }->{$type} }

sub load_type ($type_name) {
  return $Types{$type_name} //= do {
    _load_type($type_name);
  }
}

sub _load_type ($type_name) {
  my $type_file = "NXCL/01/${type_name}T.pm";
  require $type_file;
  my $pkg = "NXCL::01::${type_name}T";
  my $type_info = $NXCL::01::TypeExporter::Type_Info{$pkg};
  return make_type_object($type_name => $type_info);
}

sub _method_dict ($src) {
  my %real;
  foreach my $name (keys %$src) {
    my $info = $src->{$name};
    my $orig_code = $info->[0];
    my $code = sub ($scope, $cmb, $args, $kstack) {
      # should test type of first of $args
      $orig_code->($scope, $cmb, uncons($args)), $kstack;
    };
    my $native = make_Native($code);
    $real{$name} = $info->[1]{wrap}
      ? make_ApMeth($native)
      : $native;
  }
  return \%real;
}

sub make_type_object ($name, $info) {
  my $meta_type_hr = _method_dict($info->{static});
  my $type_hr = _method_dict($info->{method});
  my $meta_type = make_OpDict($meta_type_hr);
  my $type = mkv($meta_type, DictR ,=> $type_hr);
  $info->{type} = $type;
  return $type;
}

sub export_type_into ($into, $type_name) {
  my $pkg = "NXCL::01::${type_name}T";
  my $type_info = $NXCL::01::TypeExporter::Type_Info{$pkg};
  my %exports = %{$type_info->{exports}||{}};
  my $type = $type_info->{type};
  no strict 'refs';
  foreach my $name (sort keys %exports) {
    *{"${into}::${name}_${type_name}"} = $exports{$name}[0];
  }
  *{"${into}::${type_name}T"} = sub () { $type };
}

{
  my @opdict;
  no warnings 'redefine';
  local *make_OpDict = sub ($hash) {
    push @opdict, my $v = mkv(undef, DictR, $hash);
    $v;
  };
  my $opdict_t = load_type('OpDict');
  $_->[0] = $opdict_t for @opdict;
}

1;
