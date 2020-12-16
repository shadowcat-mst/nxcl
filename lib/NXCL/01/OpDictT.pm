package NXCL::01::OpDictT;

use NXCL::01::TypeExporter;

sub make ($hash) { _make DictR ,=> $hash }

raw method combine => sub ($scope, $args, $self, $kstack) {
  my $key = raw(car($args));
  my $value = raw($self)->{$key};
  panic unless $value;
  return evaluate_to_value($scope, $value, $kstack);
}

1;
