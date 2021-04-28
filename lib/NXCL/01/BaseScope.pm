package NXCL::01::BaseScope;

use NXCL::Package;
use NXCL::01::Utils qw(uncons);
use NXCL::01::MethodUtils;
use vars qw(@BASE_TYPES);
use NXCL::01::TypeFunctions (
  (@BASE_TYPES = qw(
    Apv Bool Combine Curry Int List Name Native
    OpDict Scope String Val Compound
  )),
  qw(make_Val make_Scope make_Native make_OpDict),
);

my %opmeth = map {
  my ($opname, $opmeth) = @$_;
  ($opname => make_Val make_Native sub ($scope, $, $args, $kstack) {
    my ($obj) = uncons $args;
    call_method($scope, $obj, $opmeth, $args, $kstack);
  })
} (
  [ '+', 'plus' ],
  [ '-', 'minus' ],
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
