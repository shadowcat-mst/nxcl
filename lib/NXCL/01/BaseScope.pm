package NXCL::01::BaseScope;

use strict;
use warnings;

sub fdot ($scope, $, $args, $kstack) {
  my ($callp, $obj) = flatten $args;
  my $ctype = type($callp);
  if ($ctype == NameT) {
    my $method = make_String raw($callp);
    return NXCL::01::ObjectT::invoker_for(
      $scope, $obj, make_List($method), $kstack
    );
  }
  panic unless $ctype == StringT or $ctype == IntT;
  return(
    [ CMB9 => $scope => $obj => make_List($callp) ],
    $kstack
  );
}

our $FDOT = make_RawNative \&fdot;

sub dot ($scope, $, $args, $kstack) {
  my @args = flatten $args;
  panic unless @args == 2; # handle invocant-less .foo() and .0 later
  my $rtype = type($args[-1]);
  if ($rtype == NameT or $rtype == IntT or $rtype == StringT) {
    return (
      [ EVAL => $scope => $args[0] ],
      cons_List(
        [ CONS => $scope => $args[-1] ],
        [ CMB9 => $scope => $FDOT ],
        $kstack
      );
    );
  }
  return (
    [ EVAL => $scope, $args ],
    cons_List(
      [ CMB9 => $scope => $FDOT ],
      $kstack
    )
  );
}

1;
