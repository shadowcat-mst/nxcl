package NXCL::TypeInfo;

use NXCL::Class;
use NXCL::Utils qw(mkv uncons);
use NXCL::OpUtils qw(JUST);
use NXCL::ReprTypes qw(ValR);
use Sub::Util qw(subname set_subname);
use NXCL::TypeFunctions qw(make_OpDict make_ApMeth make_Native);
use NXCL::TypeMethod;
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
    set_subname
      +(subname($info->[0]) =~ s/::__ANON__$/::Inst_${name}/r),
      $info->[0];
    my $native = make_Native(NXCL::TypeMethod->new(code => $info->[0]));
    $mset{$name} = $info->[1]{wrap}
      ? make_ApMeth($native)
      : $native;
  }
  $mset{evaluate} ||= do {
    state $eval = do {
      require NXCL::ExprUtils;
      $NXCL::ExprUtils::ESCAPE;
    };
  };
  my $mset_v = make_OpDict(\%mset);
  my $mset_name = $self->name.($mset_type eq 'Type' ? 'T' : '');
  $NXCL::TypeRegistry::Mset{$mset_v} = $mset_name;
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
