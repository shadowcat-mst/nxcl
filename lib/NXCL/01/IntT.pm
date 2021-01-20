package NXCL::01::IntT;

use NXCL::01::Utils qw(flatten raw panic);
use NXCL::01::ReprTypes qw(IntR);
use NXCL::01::TypeFunctions qw(IntT make_Bool);
use NXCL::01::TypeExporter;

export make => \&make;

sub make ($int) { _make IntR, => $int }

wrap method eq => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make_Bool(raw($l) == raw($r));
};

wrap method gt => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make_Bool(raw($l) > raw($r));
};

wrap method div => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make int(raw($l) / raw($r));
};

wrap method mod => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make(raw($l) % raw($r));
};

wrap method minus => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make(raw($l) - raw($r)) if defined($r);
  return make(-raw($l));
};

wrap method times => sub ($scope, $args) {
  my @ints = flatten $args;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make reduce { $a * $b }, 1, map raw($_), @ints;
};

wrap method plus => sub ($scope, $args) {
  my @ints = flatten $args;
  panic 'Must be ints' for grep type($_) ne IntT, $l, $r;
  return make reduce { $a + $b }, 0, map raw($_), @ints;
};

1;
