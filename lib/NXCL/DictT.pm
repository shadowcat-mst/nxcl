package NXCL::DictT;

use NXCL::Utils qw(panic raw uncons flatten);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypeSyntax;
use NXCL::TypeFunctions qw(
  make_KVPair make_String make_List make_Name method_Native
  just_Native list_Compound make_Bool
);

export make ($hash) { _make DictR ,=> $hash }

static new {
  my @pairs = flatten $args;
  my %setup;
  foreach my $p (@pairs) {
    my ($kp, $v) = uncons($p);
    my $kstr = raw($kp);
    $setup{$kstr} = $v;
  }
  return JUST _make DictR, => \%setup;
};

method COMBINE {
  my $key = raw((uncons($args))[0]);
  my $value = raw($self)->{$key};
  panic unless $value;
  return JUST $value;
};

method has {
  my $key = raw((uncons($args))[0]);
  return JUST make_Bool(exists raw($self)->{$key});
}

methodx pairs {
  my $hr = raw($self);
  my @pairs = map {
    make_KVPair(make_String($_), $hr->{$_})
  } sort keys %$hr;
  return JUST make_List @pairs;
}

methodx AS_PLAIN_EXPR {
  return (
    CALL(pairs => make_List($self)),
    SNOC(make_List method_Native 'AS_PLAIN_EXPR'),
    CALL('map'),
    LIST(make_Name('%')),
    CMB9(just_Native \&list_Compound),
  );
}

1;
