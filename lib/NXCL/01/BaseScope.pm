package NXCL::01::BaseScope;

use NXCL::Package;
use NXCL::01::Utils qw($NIL panic flatten);
use vars qw(@BASE_TYPES);
use NXCL::01::Types
  @BASE_TYPES = qw(
    Apv Bool Combine Curry Int List Name Native
    Object OpDict RawNative Scope String Val
  );

our %NATIVES =
  map +($_ => make_RawNative(__PACKAGE__->can($_))),
    qw(dot_lookup dot_curryable dot_curried fdot dot);

$_ = make_Apv($_) for $NATIVES{dot_curried};

our $Store = make_OpDict +{
  dot => make_Val($NATIVES{dot}),
  map +($_ => Val($Types{$_})),
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
    [ JUST => make_Curry($NATIVES{dot_curried}, $args) ],
    $kstack
  );
}

sub dot_curried ($scope, $, $args, $kstack) {
  return (
    [ JUST => make_Curry($NATIVES{dot_curried_invoke}, make_List($args)) ],
    $kstack
  );
}

sub dot_curried_invoke ($scope, $, $argsp, $kstack) {
  my ($curry, $call_args) = uncons $argsp;
  my ($method, $curried_args) = uncons $curry;
  my ($obj, $extra_args) = uncons $call_args;
  my $args = cons_List(flatten($curried_args), $extra_args);
  NXCL::01::ObjectT::invoke_method($scope, $obj, $args, $kstack);
}

sub fdot ($scope, $, $args, $kstack) {
  my ($callp, $obj) = flatten $args;
  my $ctype = type($callp);
  if ($ctype == NameT) {
    my $method = make_String raw($callp);

    if ($obj) {
      return NXCL::01::ObjectT::invoker_for(
        $scope, $obj, make_List($method), $kstack
      );
    }

    return (
      [ JUST => make_Curry($NATIVES{dot_curryable}, $method) ],
      $kstack
    );
  }

  panic unless $ctype == StringT or $ctype == IntT;

  if ($obj) {
    return (
      [ CMB9 => $scope => $obj => make_List($callp) ],
      $kstack
    );
  }

  return (
    [ JUST => make_Curry($NATIVES{dot_lookup}, make_List $callp) ],
    $kstack
  );
}

sub dot ($scope, $, $args, $kstack) {
  my @args = flatten $args;
  panic unless @args == 1 or @args == 2;
  my $rtype = type($args[-1]);
  if ($rtype == NameT or $rtype == IntT or $rtype == StringT) {

    unless (@args == 2) {
      return fdot($scope, $, $args, $kstack);
    }

    return (
      [ EVAL => $scope => make_List($args[0]) ],
      cons_List(
        [ CONS => $scope => $args[-1] ],
        [ CMB9 => $scope => $NATIVES{fdot} ],
        $kstack
      );
    );
  }
  return (
    [ EVAL => $scope, $args ],
    cons_List(
      [ CMB9 => $scope => $NATIVES{fdot} ],
      $kstack
    )
  );
}

1;
