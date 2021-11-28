package NXCL::IntT;

use List::Util qw(reduce);
use NXCL::Utils qw(flatten raw panic mset object_is);
use NXCL::ReprTypes qw(IntR);
use NXCL::TypeFunctions qw(make_Bool make_String);
use NXCL::TypePackage;

export make => \&make;

sub make ($int) { _make IntR, => $int }

method to_xcl_string => sub ($self, $) {
  return JUST make_String(''.raw($self));
};

wrap method eq => sub ($self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) == raw($r));
};

wrap method gt => sub ($self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) > raw($r));
};

wrap method quotient => sub ($self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make int(raw($self) / raw($r));
};

wrap method remainder => sub ($self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make(raw($self) % raw($r));
};

wrap method minus => sub ($self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  unless ($r) {
    return JUST make(-raw($self));
  }
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make(raw($self) - raw($r));
};

wrap method times => sub ($self, $args) {
  my @ints = flatten $args;
  my $mset = mset($self);
  panic 'Must be ints' for grep !object_is($_, $mset), @ints;
  return JUST make reduce { $a * $b } map raw($_), $self, @ints;
};

wrap method plus => sub ($self, $args) {
  my @ints = flatten $args;
  my $mset = mset($self);
  panic 'Must be ints' for grep !object_is($_, $mset), @ints;
  return JUST make reduce { $a + $b } map raw($_), $self, @ints;
};

1;
