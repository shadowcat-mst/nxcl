package NXCL::BoolT;

use NXCL::Utils qw(mset object_is panic raw flatten);
use NXCL::ReprTypes qw(BoolR);
use NXCL::TypeFunctions qw(make_Name);
use NXCL::TypeSyntax;

export make ($val) { _make BoolR ,=> 0+!!$val }

methodn AS_PLAIN_EXPR {
  return JUST make_Name(!!(raw($self)) ? 'true' : 'false')
}

method eq {
  my ($r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  my $mset = mset($self);
  panic 'Must be bools' unless object_is $r, $mset;
  return JUST make(raw($self) == raw($r));
}

methodx ifelse {
  panic 'Wrong arg count' unless 2 ==
    (my ($then, $else) = flatten $args);
  return EVAL raw($self) ? $then : $else;
}

staticn true { return JUST make(1) };
staticn false { return JUST make(0) };

export true () { make(1) }
export false () { make(0) }

1;
