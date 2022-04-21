package NXCL::TypeInfo;

use NXCL::Class;
use NXCL::Utils qw(mkv uncons);
use NXCL::OpUtils qw(JUST);
use NXCL::ReprTypes qw(ValR);
use Sub::Util qw(subname set_subname);
use NXCL::TypeFunctions qw(
  make_Dict make_ApMeth make_Native make_String
);
use NXCL::TypeMethod;
use curry;

ro 'package';

ro 'name';

lazy exports => sub { {} };

sub add_export ($self, $name, $code) {
  set_subname
    +(subname($code) =~ s/::__ANON__$/::Export_${name}/r),
      $code;
  $self->exports->{"${name}_${\$self->name}"} = $code;
  return;
}

sub _add ($self, $type, $name, $code, $opts) {
  my $type_store = "${type}s";
  my $type_prefix = ucfirst($type);
  set_subname
    +(subname($code) =~ s/::__ANON__$/::${type_prefix}_${name}/r),
      $code;
  $self->$type_store->{$name} = [ $code, $opts ];
  return;
}

lazy methods => sub { {} };

sub add_method_apv ($self, $name, $code) {
  $self->_add(method => $name, $code, { wrap => 1 });
}

sub add_method_opv ($self, $name, $code) {
  $self->_add(method => $name, $code, {});
}

lazy statics => sub { {} };

sub add_static_apv ($self, $name, $code) {
  $self->_add(static => $name, $code, { wrap => 1 });
}

sub add_static_opv ($self, $name, $code) {
  $self->_add(static => $name, $code, {});
}

lazy inst_mset => sub ($self) { $self->_mset_of(Inst => $self->methods) };

lazy type_mset => sub ($self) { $self->_mset_of(Type => $self->statics) };

sub make ($self, @v) { mkv($self->inst_mset, @v) }

lazy type => sub ($self) { mkv($self->type_mset, ValR ,=> $self->inst_mset) };

sub _IDENTITY {
  state $id = do {
    require NXCL::ExprUtils;
    $NXCL::ExprUtils::ESCAPE;
  };
}

sub _mset_of ($self, $mset_type, $proto) {
  my %mset;
  foreach my $name (keys %$proto) {
    my $info = $proto->{$name};
    my $native = make_Native(NXCL::TypeMethod->new(code => $info->[0]));
    $mset{$name} = $info->[1]{wrap}
      ? make_ApMeth($native)
      : $native;
  }
  $mset{EVALUATE} ||= _IDENTITY;
  my $mset_name = $self->name.($mset_type eq 'Type' ? 'T' : '');
  $mset{to_xcl_string} ||= make_Native(NXCL::TypeMethod->new(
    code => sub ($self, $) {
      # use ['0x...'] since a string isn't actually combinable so eval-ing
      # this will throw an exception - roundtrippability would be preferable
      # but this will do as a fallback for now
      return JUST make_String(
        "${mset_name}['0x".sprintf("%x", Scalar::Util::refaddr $self)."']"
      )
    }
  ));
  my $mset_v = make_Dict(\%mset);
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
