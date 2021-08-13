package NXCL::ScopenerT;

use NXCL::Utils qw(uncons raw panic rnilp flatten);
use NXCL::OpUtils;
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(
  make_List cons_List empty_List
  make_Native
);
use NXCL::TypePackage;

export make => \&make;

sub make ($type) { _make ValR ,=> $type }

method combine => sub {
  panic "Can't combine scopener";
};

sub restore ($scope, $, $args) {
  return (
    rnilp($args)
      ? CALL(but_closed => make_List($scope))
      : CALL(but_intro_as => cons_List($scope, $args))
  );
}

our $RESTORE = make_Native \&restore;

sub assign_evaled ($scope, $cmb, $args) {
  my ($value, $self, $to) = flatten($args);
  my $old_intro = raw($scope)->{intro_as};
  return (
    CALL(but_intro_as => make_List($scope, raw($self))),
    RPLS(),
    CALL(assign_value => make_List($to, $value)),
    DROP(),
    CMB9($RESTORE, make_List($old_intro // ())),
    RPLS(),
    JUST($value),
  );
}

our $ASSIGN_EVALED = make_Native \&assign_evaled;

method assign_via_call => sub ($scope, $cmb, $self, $args) {
  my ($payloadp, $valuep) = flatten($args);
  my ($payload) = uncons($payloadp);
  return (
    EVAL($valuep),
    SNOC(make_List $self, $payload),
    CMB9($ASSIGN_EVALED),
  );
};

1;
