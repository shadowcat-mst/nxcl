package NXCL::01::BoolT;

use NXCL::01::TypeExporter;

sub make ($val) { _make BoolR ,=> 0+!!$val }

wrap method eq => sub ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be bools' for grep $Types{Bool} ne $_, $l, $r;
  return make(raw($l) == raw($r));
}

raw method if => sub ($scope, $args, $, $kstack) {
  panic 'Wrong arg count' unless 3 ==
    my ($bool, $then, $else) = flatten $args;
  return (
    [ EVAL => raw($bool) ? $then : $else ],
    $kstack,
  );
}

thunk static true => sub ($, $) { make(1) }
thunk static false => sub ($, $) { make(0) }

1;
