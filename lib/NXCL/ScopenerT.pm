package NXCL::ScopenerT;

use NXCL::Utils qw(uncons raw panic rnilp flatten);
use NXCL::OpUtils;
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(empty_List make_IntroScope);
use NXCL::TypePackage;

export make => \&make;

sub make ($type) { _make ValR ,=> $type }

method assign_via_call => sub ($scope, $cmb, $self, $args) {
  my ($targetp, $valuep) = flatten($args);
  my ($target) = uncons($targetp);
  my $type = raw($self);
  my $iscope = make_IntroScope($scope, $type);
  return (
    EVAL($valuep),
    OVERCTX($self, $iscope, [
      SNOC(empty_List),
      CONS($target),
      CALL('assign_value'),
    ])
  );
};

1;
