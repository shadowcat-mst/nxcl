package NXCL::01::TypeInfo;

use NXCL::Class;
use NXCL::01::Utils qw(mkv);
use NXCL::01::ReprTypes qw(ValR);

our %Registry;

ro 'package';

ro 'name';

lazy exports => sub { {} };

sub add_export ($self, $name, $code) {
  $self->exports->{"${$name}_${\$self->name}"} = $code;
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

lazy inst_mset => sub ($self) { $self->_mset_of($self->methods) };

lazy type_mset => sub ($self) { $self->_mset_of($self->statics) };

sub make ($self, @v) { mkv($self->inst_mset, @v) }

lazy type => sub ($self) { mkv($self->type_mset, ValR ,=> $self->inst_mset) };

sub _mset_of ($self, $proto) {
  my %real;
  foreach my $name (keys %$proto) {
    my $info = $proto->{$name};
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
  return make_OpDict(\%real);
}

sub export_for ($self, $name) {
  my $my_name = $self->name;
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
