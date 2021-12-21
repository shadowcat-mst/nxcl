package NXCL::IntT;

use List::Util qw(reduce);
use NXCL::Utils qw(flatten raw panic mset object_is);
use NXCL::ReprTypes qw(IntR);
use NXCL::TypeFunctions qw(make_Bool make_String);
use NXCL::TypeSyntax;

export make ($int) { _make IntR, => $int }

methodn to_xcl_string {
  return JUST make_String(''.raw($self));
}

method eq {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) == raw($r));
}

method gt {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) > raw($r));
}

method lt {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) < raw($r));
}

method ge {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) >= raw($r));
}

method le {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) <= raw($r));
}

method quotient {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make int(raw($self) / raw($r));
}

method remainder {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make(raw($self) % raw($r));
}

method minus {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  unless ($r) {
    return JUST make(-raw($self));
  }
  my $mset = mset($self);
  panic 'Must be ints' unless object_is $r, $mset;
  return JUST make(raw($self) - raw($r));
}

method times {
  my @ints = flatten $args;
  my $mset = mset($self);
  panic 'Must be ints' for grep !object_is($_, $mset), @ints;
  return JUST make reduce { $a * $b } map raw($_), $self, @ints;
}

method plus {
  my @ints = flatten $args;
  my $mset = mset($self);
  panic 'Must be ints' for grep !object_is($_, $mset), @ints;
  return JUST make reduce { $a + $b } map raw($_), $self, @ints;
}

1;
