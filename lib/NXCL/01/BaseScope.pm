package NXCL::01::BaseScope;

use strict;
use warnings;

my %members = %NXCL::01::Runtime::Types;

sub define ($scope, $lst) {
  my ($name, $args) = uncons $lst;
  $members{raw($name)} = nxceval $scope, $args;
}

use NXCL::01::Inline;

define 'current-scope' fexpr () { callscope };
define 'escape' fexpr (x) { x };
define 'identity' lambda (x) { x };
define 'list' fexpr @ { thisargs };
