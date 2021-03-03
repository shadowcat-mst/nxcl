package NXCL::01::TypeInfo;

use NXCL::Class;
use NXCL::01::Utils qw(mkv);
use NXCL::01::ReprTypes qw(ValR);
use Sub::Util qw(set_subname);
use NXCL::01::TypeFunctions qw(make_OpDict make_ApMeth make_Native);
use curry;

ro 'package';

ro 'name';

lazy exports => sub { {} };

sub add_export ($self, $name, $code) {
  $self->exports->{"${name}_${\$self->name}"} = $code;
}

lazy methods => sub { {} };

sub add_method ($self, $name, $code) {
  $self->methods->{$name} = [ $code ];
}

lazy statics => sub { {} };

sub add_static ($self, $name, $code) {
  $self->statics->{$name} = [ $code ];
}

sub mark_wrapped ($self, $info) { $info->[1]{wrap} = 1; $info }

lazy inst_mset => sub ($self) { $self->_mset_of(Inst => $self->methods) };

lazy type_mset => sub ($self) { $self->_mset_of(Type => $self->statics) };

sub make ($self, @v) { mkv($self->inst_mset, @v) }

lazy type => sub ($self) { mkv($self->type_mset, ValR ,=> $self->inst_mset) };

sub _mset_of ($self, $mset_type, $proto) {
  my %mset;
  foreach my $name (keys %$proto) {
    my $info = $proto->{$name};
    my $orig_code = $info->[0];
    my $code = sub ($scope, $cmb, $args, $kstack) {
      # should test type of first of $args
      $orig_code->($scope, $cmb, uncons($args)), $kstack;
    };
    my $subname = join('::', $self->package, "${mset_type}_${name}");
    my $native = make_Native(set_subname $subname => $code);
    $mset{$name} = $info->[1]{wrap}
      ? make_ApMeth($native)
      : $native;
  }
  my $mset_v = make_OpDict(\%mset);
  $NXCL::01::TypeRegistry::Mset{$mset_v} = join('_', $self->name, $mset_type);
  return $mset_v;
}

sub export_for ($self, $name) {
  my $my_name = $self->name;
  if ($name eq $my_name) {
    return $self->curry::type;
  }
  if ($name eq "${my_name}_Inst") {
    my $inst_mset = $self->inst_mset;
    return sub () { $inst_mset };
  }
  if (my $export = $self->exports->{$name}) {
    return $export;
  }
  die "No such export ${name} from type ${my_name}";
}

1;
