package NXCL::01::IntT;

use NXCL::01::Utils qw(flatten raw panic);
use NXCL::01::ReprTypes qw(IntR);
use NXCL::01::TypeFunctions qw(IntT make_Bool);
use NXCL::01::TypeExporter;

export make => \&make;

sub make ($int) { _make IntR, => $int }

wrap method eq => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($_);
  panic 'Must be ints' unless type($r) == $type;
  return (
    [ JUST => make_Bool(raw($self) == raw($r)) ],
  );
};

wrap method gt => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($_);
  panic 'Must be ints' unless type($r) == $type;
  return (
    [ JUST => make_Bool(raw($self) > raw($r)) ],
  );
};

wrap method div => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($_);
  panic 'Must be ints' unless type($r) == $type;
  return (
    [ JUST => make int(raw($self) / raw($r)) ],
  );
};

wrap method mod => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($_);
  panic 'Must be ints' unless type($r) == $type;
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
  my $type = type($_);
  panic 'Must be ints' unless type($r) == $type;
  return (
    [ JUST => make(raw($self) - raw($r)) ],
  );
};

wrap method times => sub ($scope, $cmb, $self, $args) {
  my @ints = flatten $args;
  my $type = type($_);
  panic 'Must be ints' for grep type($_) != $type, @ints;
  return make reduce { $a * $b } map raw($_), $self, @ints;
};

wrap method times => sub ($scope, $cmb, $self, $args) {
  my @ints = flatten $args;
  my $type = type($_);
  panic 'Must be ints' for grep type($_) != $type, @ints;
  return make reduce { $a + $b } map raw($_), $self, @ints;
};

1;
