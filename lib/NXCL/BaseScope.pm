package NXCL::BaseScope;

use NXCL::Package;
use NXCL::Utils qw(uncons);
use NXCL::MethodUtils;
use Sub::Util qw(set_subname);
use vars qw(@BASE_TYPES);
use NXCL::TypeFunctions (
  (@BASE_TYPES = qw(
    Apv Bool Combine Curry Int List Name Native
    OpDict Scope String Val Compound
  )),
  qw(make_Val make_Scope make_Native make_OpDict),
);
use NXCL::BaseOps qw(%OP_MAP);

my %opmeth = map {
  my ($opname, $opmeth) = ($_, $OP_MAP{$_});
  ($opname => make_Val make_Native set_subname "dot_${opmeth}" =>
    sub ($scope, $, $args, $kstack) {
      my ($obj) = uncons $args;
      call_method($scope, $obj, $opmeth, $args, $kstack);
    })
} (
  sort keys %OP_MAP
);

our $Store = make_OpDict +{
  dot => make_Val($DOT),
  '.' => make_Val($DOT),
  %opmeth,
  map +($_ => make_Val(__PACKAGE__->can($_)->())),
    @BASE_TYPES
};

our $Scope = make_Scope $Store;

sub scope () { $Scope }

1;