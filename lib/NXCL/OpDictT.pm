package NXCL::OpDictT;

use NXCL::Utils qw(panic raw uncons);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypePackage;

export make => sub ($hash) { _make DictR ,=> $hash };

method COMBINE => sub ($self, $args) {
  my $key = raw((uncons($args))[0]);
  my $value = raw($self)->{$key};
  panic unless $value;
  return JUST $value;
};

1;
