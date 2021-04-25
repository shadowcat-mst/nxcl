package NXCL::01::MethodUtils;

use NXCL::Exporter;
use NXCL::01::Utils qw(panic mset raw flatten uncons);
use NXCL::01::TypeFunctions qw(
  OpDict_Inst Native_Inst Name_Inst String_Inst Int_Inst
  make_List make_String make_Curry make_Native make_Apv
);
use NXCL::01::TypeRegistry;

our @EXPORT = qw(call_method lookup_method $ndot);

our $ndot = make_Native \&dot;

our %N =
  map +($_ => make_Native(__PACKAGE__->can($_))),
    qw(dot_lookup dot_curryable dot_curried dot_f);

$_ = make_Apv($_) for $N{dot_curried};

sub call_method ($scope, $self, $methodp, $args, $kstack) {
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
    if (mset($handler) == Native_Inst) {
      return raw($handler)->($scope, $handler, $args, $kstack);
    }
    return (
      [ CMB9 => $scope, $handler, $args ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $mset, make_List($method_String) ],
    [ CMB6 => $scope, $args ],
    $kstack
  );
}

sub lookup_method ($scope, $self, $methodp, $kstack) {
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
    return (
      [ JUST => make_Curry($handler, make_List($self)) ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, $mset, make_List($method_String) ],
    [ CMB9 => $scope => make_Native(sub ($scope, $cmb, $args, $kstack) {
        make_Curry((uncons($args))[0], make_List($self))
    }) ],
    $kstack
  );
}

sub dot_lookup ($scope, $, $args, $kstack) {
  my ($lookup, $obj) = flatten $args;
  return (
    [ CMB9 => $scope => $obj => make_List($lookup) ],
    $kstack
  );
}

sub dot_curryable ($scope, $, $args, $kstack) {
  return (
    [ JUST => make_Curry($N{dot_curried}, $args) ],
    $kstack
  );
}

sub dot_curried ($scope, $, $argsp, $kstack) {
  my ($method, $args) = uncons $argsp;
  my ($obj) = uncons $args;
  call_method($scope, $obj, $method, $args, $kstack);
}

sub dot_f ($scope, $, $args, $kstack) {
  my ($callp, $obj) = flatten $args;
  my $ctype = mset($callp);
  if ($ctype == Name_Inst) {
    my $method = make_String raw($callp);

    if ($obj) {
      return lookup_method($scope, $obj, $method, $kstack);
    }

    return (
      [ JUST => make_Curry($N{dot_curryable}, make_List $method) ],
      $kstack
    );
  }

  panic unless $ctype == String_Inst or $ctype == Int_Inst;

  if ($obj) {
    return (
      [ CMB9 => $scope => $obj => make_List($callp) ],
      $kstack
    );
  }

  return (
    [ JUST => make_Curry($N{dot_lookup}, make_List $callp) ],
    $kstack
  );
}

sub dot ($scope, $cmb, $args, $kstack) {
  my @args = flatten $args;
  panic unless @args == 1 or @args == 2;
  my $mset = mset($args[-1]);
  if ($mset == Name_Inst or $mset == Int_Inst or $mset == String_Inst) {

    unless (@args == 2) {
      return dot_f($scope, undef, $args, $kstack);
    }

    return (
      [ EVAL => $scope => make_List($args[0]) ],
      [ CONS => $args[-1] ],
      [ CMB9 => $scope => $N{dot_f} ],
      $kstack
    );
  }
  return (
    [ EVAL => $scope, $args ],
    [ CMB9 => $scope => $N{dot_f} ],
    $kstack
  );
}

1;
