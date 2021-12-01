package NXCL::DictT;

use NXCL::Utils qw(panic raw uncons flatten);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypePackage;

export make => sub ($hash) { _make DictR ,=> $hash };

wrap static new => sub ($self, $args) {
  my @pairs = flatten $args;
  my %setup;
  foreach my $p (@pairs) {
    my ($kp, $v) = uncons($p);
    my $kstr = raw($kp);
    $setup{$kstr} = $v;
  }
  return JUST _make DictR, => \%setup;
};

wrap method COMBINE => sub ($self, $args) {
  my $key = raw((uncons($args))[0]);
  my $value = raw($self)->{$key};
  panic unless $value;
  return JUST $value;
};

1;
