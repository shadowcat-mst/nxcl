package NXCL::01::OpDictT;

use NXCL::01::Utils qw(panic raw uncons);
use NXCL::01::ReprTypes qw(DictR);
use NXCL::01::TypeExporter;

export make => sub ($hash) { _make DictR ,=> $hash };

method combine => sub ($scope, $self, $args, $kstack) {
  my $key = raw(uncons($args)[0]);
  my $value = raw($self)->{$key};
  panic unless $value;
  return ([ JUST => $value ], $kstack);
};

1;
