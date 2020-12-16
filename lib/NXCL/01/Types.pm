package NXCL::01::Types;

use strict;
use warnings;
use experimental 'signatures';
use Scalar::Util qw(weaken);
use NXCL::01::TypeExporter ();
use NXCL::01::Utils qw(make_string_combiner);

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

sub make_type_object ($type) {
  my ($name, $statics, $methods) = @{$type}{qw(short_name statics methods)};
  my $meta_type = mkv OpDictT ,=> DictR ,=> _expand_methods($statics);
  return mkv($meta_type, mkv OpDictT ,=> DictR ,=> {
    evaluate => \&evaluate_to_value,
    combine => \&not_combinable,
    'type-shortname' => make_string_combiner($name),
    %{_expand_methods($methods},
  });
}

# let _expand_methods (Dict d) {
#   d.map(
#     ((name, (code, attrs))) => {
#       :($name) $(
#         { ?: attrs,'wrap' make_Apv(this) this }
#         [ [ ?: attrs.'raw' make_RawNative make_Native ] code ]
#       )
#     }
#   )
# }

sub _expand_methods ($hash) {
  return +{
    map {
      my ($name, $code, $attrs) = ($_, @{$hash->{$_}});
      ($name =>
        map { $attrs->{wrap} ? make_Apv($_) : $_ }
        ($attrs->{raw} ? make_RawNative($code) : make_Native($code))
      )
    } keys %$hash;
  };
}

sub _load_type ($name) {
  my $type_file = "NXCL/01/${name}T.pm";
  require $type_file;
  my $pkg = "NXCL::01::${name}T";
  my %type = (
    short_name => $name,
    maker => $pkg->can('make'),
    %{$NXCL::01::TypeExporter::Type_Info{$pkg}},
  );
  return make_type_object(\%type);
}

sub export_type_into ($into, $type) {
  my $type_name = $type->{name};
  {
    no strict 'refs';
    *{"${into}::${type_name}"} = $type->{maker};
  }
}

for my $type (load_type('OpDict')) {
  weaken(my $weak = $type);
  $type->[0] = $weak;
}

1;
