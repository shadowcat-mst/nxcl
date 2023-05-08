package NXCL::StringT;

use NXCL::Utils qw(panic flatten raw mset object_is);
use NXCL::ReprTypes qw(CharsR);
use NXCL::TypeFunctions qw(make_Bool);
use NXCL::TypeSyntax;

export make ($string) { _make CharsR, => $string }

methodn AS_PLAIN_EXPR {
  return JUST $self
}

method eq {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be strings' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) eq raw($r));
}

method gt {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be strings' unless object_is $r, $mset;
  return JUST make_Bool(raw($self) gt raw($r));
}

method concat {
  my @string = flatten $args;
  my $mset = mset($self);
  panic 'Must be strings' for grep !object_is($_, $mset), @string;
  return JUST make(join '', map raw($_), $self, @string);
}

method sprintf {
  # This should have some validation
  return JUST make(sprintf raw($self), map raw($_), flatten($args))
}

method substr {
  my ($start, $length) = flatten $args, 2;
  return JUST make substr(raw($self), raw($start), raw($length));
}

1;
