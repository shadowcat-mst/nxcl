package NXCL::KeyT;

use NXCL::Utils qw(uncons raw);
use NXCL::TypeFunctions qw(make_Pair);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

export make => sub ($val) { _make ValR ,=> $val };

wrap static new => sub ($scope, $cmb, $self, $args) {
  my ($key) = uncons($args);
  return ([ JUST => _make ValR ,=> $key ]);
};

wrap method combine => sub ($scope, $cmb, $self, $args) {
  my ($value) = uncons($args);
  return ([ JUST => make_Pair(raw($self), $value) ]);
};

1;
