package NXCL::StringT;

use NXCL::Utils qw(panic flatten raw mset object_is);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::TypePackage;

export make => \&make;

sub make ($string) { _make CharsR, => $string }

method to_xcl_string => sub ($scope, $self, $) {
  # this is wrong
  return JUST make("'".raw($self)."'");
};

wrap method eq => sub ($scope, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be strings' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) eq raw($r));
};

wrap method gt => sub ($scope, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be strings' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) gt raw($r));
};

wrap method concat => sub ($scope, $self, $args) {
  my @string = flatten $args;
  my $mset = mset($self);
  panic 'Must be strings' for grep !object_is($_, $mset), @string;
  return JUST make(join '', map raw($_), $self, @string);
};

wrap method sprintf => sub ($scope, $self, $args) {
  # This should have some validation
  return JUST make(sprintf raw($self), map raw($_), flatten($args))
};

1;
