package NXCL::BoolT;

use NXCL::Utils qw(mset object_is panic raw flatten);
use NXCL::ReprTypes qw(BoolR);
use NXCL::TypeFunctions qw(make_String);
use NXCL::TypePackage;

export make => \&make;

sub make ($val) { _make BoolR ,=> 0+!!$val };

method to_xcl_string => sub ($self, $) {
  return JUST make_String(!!(raw($self)) ? 'true' : 'false');
};

wrap method eq => sub ($self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be bools' unless object_is $r, $mset;
  return JUST make(raw($self) == raw($r));
};

method ifelse => sub ($self, $args) {
  panic 'Wrong arg count' unless 2 ==
    (my ($then, $else) = flatten $args);
  return EVAL raw($self) ? $then : $else;
};

static true => sub { return JUST make(1) };
static false => sub { return JUST make(0) };

export true => sub { make(1) };
export false => sub { make(0) };

1;
