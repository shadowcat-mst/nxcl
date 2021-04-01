package NXCL::01::BaseScope;

use NXCL::Package;
use NXCL::01::Utils qw(panic flatten mset raw uncons);
use NXCL::01::MethodUtils;
use vars qw(@BASE_TYPES);
use NXCL::01::TypeFunctions
  (@BASE_TYPES = qw(
    Apv Bool Combine Curry Int List Name Native
    OpDict Scope String Val
  )),
  qw(
    Name_Inst String_Inst Int_Inst
    make_Apv make_Val make_OpDict make_List make_Native make_Curry
    make_String cons_List make_Scope
  );

our %N =
  map +($_ => make_Native(__PACKAGE__->can($_))),
    qw(dot_lookup dot_curryable dot_curried fdot dot);

$_ = make_Apv($_) for $N{dot_curried};

our $Store = make_OpDict +{
  dot => make_Val($N{dot}),
  map +($_ => make_Val(__PACKAGE__->can($_)->())),
    @BASE_TYPES
};

our $Scope = make_Scope $Store;

sub scope () { $Scope }

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

sub fdot ($scope, $, $args, $kstack) {
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
      return fdot($scope, undef, $args, $kstack);
    }

    return (
      [ EVAL => $scope => make_List($args[0]) ],
      [ CONS => $args[-1] ],
      [ CMB9 => $scope => $N{fdot} ],
      $kstack
    );
  }
  return (
    [ EVAL => $scope, $args ],
    [ CMB9 => $scope => $N{fdot} ],
    $kstack
  );
}

1;
