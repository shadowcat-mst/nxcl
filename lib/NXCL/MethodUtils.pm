package NXCL::MethodUtils;

use NXCL::Exporter;
use NXCL::Utils qw(panic mset object_is raw flatten uncons);
use NXCL::OpUtils;
use NXCL::TypeFunctions qw(
  OpDict_Inst Native_Inst Name_Inst String_Inst Int_Inst
  make_List make_String cons_Curry make_Curry make_Native make_Apv
);
use NXCL::TypeRegistry;

our @EXPORT = qw(call_method lookup_method $DOT $DOT_F);

our $DOT = make_Native \&dot;

our %N =
  map +($_ => make_Native(__PACKAGE__->can($_))),
    qw(dot_lookup dot_curryable dot_curried dot_f);

our $DOT_F = $N{dot_f};

$_ = make_Apv($_) for $N{dot_curried};

sub call_method ($scope, $self, $methodp, $args) {
  panic "Undefined self" unless defined($self);
  my ($method_name, $method_String) = (
    ref($methodp)
      ? (raw($methodp), $methodp)
      : ($methodp, make_String($methodp))
  );
  my $mset = mset($self) // panic "Undefined mset for ${self}";
  if (object_is $mset, OpDict_Inst) {
    panic "No handler for ${method_name} on ".mset_name($mset)
      ." (mset has methods: "
      .(join(', ', sort keys %{raw($mset)})||'(none)').")"
      unless my $handler = raw($mset)->{$method_name};
    if (object_is $handler, Native_Inst) {
      return raw($handler)->($scope, $handler, $args);
    }
    return CMB9 $handler, $args;
  }
  return (
    CMB9($mset, make_List($method_String)),
    CMB6($args),
  );
}

sub lookup_method ($scope, $self, $methodp) {
  my ($method_name, $method_String) = (
    ref($methodp)
      ? (raw($methodp), $methodp)
      : ($methodp, make_String($methodp))
  );
  my $mset = mset($self);
  if (mset($mset) == OpDict_Inst) {
    panic "No handler for ${method_name} on ".mset_name($mset)
      ." (mset has methods: "
      .(join(', ', sort keys %{raw($mset)})||'(none)').")"
      unless my $handler = raw($mset)->{$method_name};
    return JUST make_Curry($handler, $self);
  }
  return (
    CMB9($mset, make_List($method_String)),
    CMB9(make_Native(sub ($scope, $cmb, $args) {
      make_Curry((uncons($args))[0], $self)
    })),
  );
}

sub dot_lookup ($scope, $, $args) {
  my ($lookup, $obj) = flatten $args;
  return CMB9 $obj => make_List($lookup);
}

sub dot_curryable ($scope, $, $args) {
  return JUST cons_Curry($N{dot_curried}, $args);
}

sub dot_curried ($scope, $, $argsp) {
  my ($method, $args) = uncons $argsp;
  my ($obj) = uncons $args;
  call_method($scope, $obj, $method, $args);
}

sub dot_f ($scope, $, $args) {
  my ($callp, $obj) = flatten $args;
  my $ctype = mset($callp);
  if ($ctype == Name_Inst) {
    my $method = make_String raw($callp);

    if ($obj) {
      return lookup_method($scope, $obj, $method);
    }

    return JUST make_Curry($N{dot_curryable}, $method);
  }

  panic unless $ctype == String_Inst or $ctype == Int_Inst;

  if ($obj) {
    return CMB9 $obj => make_List($callp);
  }

  return JUST make_Curry($N{dot_lookup}, $callp);
}

sub dot ($scope, $cmb, $args) {
  my @args = flatten $args;
  panic unless @args == 1 or @args == 2;
  my $mset = mset($args[-1]);
  if ($mset == Name_Inst or $mset == Int_Inst or $mset == String_Inst) {

    unless (@args == 2) {
      return dot_f($scope, undef, $args);
    }

    return (
      EVAL(make_List($args[0])),
      CONS($args[-1]),
      CMB9($N{dot_f}),
    );
  }
  return (
    EVAL($args),
    CMB9($N{dot_f}),
  );
}

1;
