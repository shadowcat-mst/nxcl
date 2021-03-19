package NXCL::01::IntT;

use NXCL::01::Utils qw(flatten raw panic mset);
use NXCL::01::ReprTypes qw(IntR);
use NXCL::01::TypeFunctions qw(make_Bool);
use NXCL::01::TypePackage;

export make => \&make;

sub make ($int) { _make IntR, => $int }

wrap method eq => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless mset($r) == $mset;
  return (
    [ JUST => make_Bool(raw($self) == raw($r)) ],
  );
};

wrap method gt => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless mset($r) == $mset;
  return (
    [ JUST => make_Bool(raw($self) > raw($r)) ],
  );
};

wrap method div => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless mset($r) == $mset;
  return (
    [ JUST => make int(raw($self) / raw($r)) ],
  );
};

wrap method mod => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless mset($r) == $mset;
  return (
    [ JUST => make(raw($self) % raw($r)) ],
  );
};

wrap method minus => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  unless ($r) {
    return (
      [ JUST => make(-raw($self)) ],
    );
  }
  my $mset = mset($self);
  panic 'Must be ints' unless mset($r) == $mset;
  return (
    [ JUST => make(raw($self) - raw($r)) ],
  );
};

wrap method times => sub ($scope, $cmb, $self, $args) {
  my @ints = flatten $args;
  my $mset = mset($self);
  panic 'Must be ints' for grep mset($_) != $mset, @ints;
  return make reduce { $a * $b } map raw($_), $self, @ints;
};

wrap method times => sub ($scope, $cmb, $self, $args) {
  my @ints = flatten $args;
  my $mset = mset($self);
  panic 'Must be ints' for grep mset($_) != $mset, @ints;
  return make reduce { $a + $b } map raw($_), $self, @ints;
};

1;
