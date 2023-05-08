package NXCL::ListT;

use NXCL::Utils qw(
  uncons flatten rconsp rnilp panic rtype raw
);
use NXCL::ReprTypes qw(ConsR NilR);
use NXCL::TypeFunctions qw(
  make_String make_Native method_Native make_Combine
);
use NXCL::ExprUtils qw($ESCAPE);
use NXCL::TypeSyntax;

export make (@members) { cons(@members, _make(NilR)) }

export cons (@members) {
  panic unless my $ret = pop @members;
  foreach my $m (reverse @members) {
    $ret = _make ConsR ,=> $m, $ret;
  }
  return $ret;
}

export empty { _make(NilR) }

staticn new_empty { return JUST empty }

methodn first {
  panic unless rconsp $self;
  my ($first) = uncons $self;
  return JUST $first;
}

methodn rest {
  panic unless rconsp $self;
  my (undef, $rest) = uncons $self;
  return JUST $rest;
}

methodn EVALUATE {
  if (rnilp $self) {
    return JUST $self;
  }
  my ($car, $cdr) = uncons $self;
  return (
    EVAL($car),
    ECDR($cdr),
  );
}

method concat {
  my ($concat) = uncons($args);
  return JUST cons(flatten($self), $concat);
}

method COMBINE {
  panic "List.COMBINE called without an index" if rnilp($args);
  my $idx = raw((uncons($args))[0]);
  my $value = $self;
  (undef, $value) = uncons($value) for 1..$idx;
  my ($car) = uncons($value);
  panic unless $car;
  return JUST $car;
}

sub map_continue ($args, $cb) {
  my ($func, $val, $rest) = flatten($args, 2);
  my ($mapname, @vals) = $cb->($val);
  return (
    CALL($mapname => make($rest, $func)),
    (map CONS($_), @vals),
  );
}

my $map_continue = make_Native sub {
  map_continue(@_, sub ($v) { (map => $v) });
};

my $lmap_continue = make_Native sub {
  map_continue(@_, sub ($v) {
    panic "lmap_continue given non-list" unless rconsp($v);
    return (lmap => reverse flatten($v));
  });
};

sub map_body ($self, $args, $continue) {
  if (rnilp($self)) {
    return JUST $self;
  }
  my ($car, $cdr) = uncons($self);
  my ($func) = uncons($args);
  return (
    # This is messy but seems to currently be the least worst way to avoid
    # the list element getting evaluated on the way into the function call.
    CMB9($func => make(make_Combine($ESCAPE, $car))),
    SNOC($cdr),
    CONS($func),
    CMB9($continue),
  );
};

method map { map_body($self, $args, $map_continue) }
method lmap { map_body($self, $args, $lmap_continue) }

my $each_continue = make_Native sub {
  map_continue(@_, sub ($v) {
    return (each => ());
  });
};

method each { map_body($self, $args, $each_continue) }

methodx ASSIGN_VALUE {
  return JUST($self) if rnilp($self);
  my ($scar, $scdr) = uncons($self);
  my ($arg) = uncons($args);
  panic "WHAT" if rnilp($arg);
  my ($acar, $acdr) = uncons($arg);
  return (
    CALL(ASSIGN_VALUE => make($scar, $acar)),
    DROP(),
    CALL(ASSIGN_VALUE => make($scdr, $acdr)),
  );
}

methodx AS_PLAIN_EXPR {
  return CALL(map => make($self, method_Native('AS_PLAIN_EXPR')));
}

1;
