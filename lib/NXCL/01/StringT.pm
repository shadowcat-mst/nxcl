package NXCL::01::StringT;

use NXCL::01::Utils qw(panic flatten);
use NXCL::01::ReprTypes qw(CharsR);
use NXCL::01::TypeFunctions qw(make_Bool);
use NXCL::01::TypePackage;

export make => \&make;

sub make ($string) { _make CharsR, => $string }

wrap method eq => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($self);
  panic 'Must be strings' unless type($r) == $type;
  return (
    make_Bool(raw($self) eq raw($r)),
  );
};

wrap method gt => sub ($scope, $cmb, $self, $args) {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $type = type($self);
  panic 'Must be strings' unless type($r) == $type;
  return (
    make_Bool(raw($self) gt raw($r)),
  );
};

wrap method concat => sub ($scope, $cmb, $self, $args) {
  my @string = flatten $args;
  my $type = type($self);
  panic 'Must be strings' for grep type($_) != $type, @string;
  return (
    _make(join '', map raw($_). $self, @string),
  );
};

1;
