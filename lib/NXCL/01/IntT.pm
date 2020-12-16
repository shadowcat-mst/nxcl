package NXCL::01::IntT;

use NXCL::01::TypeExporter;

sub make ($int) { _make IntR, => $int }

wrap method eq => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return make_Bool(raw($l) == raw($r));
}

wrap method gt => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return make_Bool(raw($l) > raw($r));
}

wrap method div => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return make int(raw($l) / raw($r));
}

wrap method mod => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return make(raw($l) % raw($r));
}

wrap method minus => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, grep defined, $l, $r;
  return make(raw($l) - raw($r)) if defined($r);
  return make(-raw($l));
}

wrap method times => sub ($scope, $args) {
  my @ints = flatten $args;
  panic 'Must be ints' for grep $Types{Int} ne $_, @ints;
  return make reduce { $a * $b }, 1, map raw($_), @ints;
}

wrap method plus => sub ($scope, $args) {
  my @ints = flatten $args;
  panic 'Must be ints' for grep $Types{Int} ne $_, @ints;
  return make reduce { $a + $b }, 0, map raw($_), @ints;
}

1;
