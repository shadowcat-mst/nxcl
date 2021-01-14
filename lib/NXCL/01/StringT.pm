package NXCL::01::StringT;

use NXCL::01::TypeExporter;

sub make ($string) { _make CharsR, => $string }

wrap method eq => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be strings' for grep $Types{String} ne $_, $l, $r;
  make_Bool(raw($l) eq raw($r));
}

wrap method gt => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be strings' for grep $Types{String} ne $_, $l, $r;
  make_Bool(raw($l) gt raw($r));
}

wrap method concat => sub ($scope, $args) {
  my @string = flatten $args;
  panic 'Must be strings' for grep $Types{String} ne $_, @string;
  make(join '', map raw($_). @string);
}

1;
