package NXCL::ListT;

use NXCL::Utils qw(
  uncons flatten rconsp rnilp panic rtype raw
);
use NXCL::ReprTypes qw(ConsR NilR);
use NXCL::TypeFunctions qw(make_String make_Native);
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

methodn to_xcl_string {
  CALL(_to_xcl_string => make($self))
}

methodx _to_xcl_string {
  if (rnilp($self)) {
    return JUST make_String(
      '('.join(', ', map raw($_), reverse flatten $args).')'
    );
  }
  my ($car, $cdr) = uncons($self);
  return (
    CALL('to_xcl_string' => make($car)),
    SNOC($args),
    CONS($cdr),
    CALL('_to_xcl_string'),
  );
}

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

sub map_continue ($args, $flat = undef) {
  my ($func, $argcdr) = uncons($args);
  my ($val, $rest) = uncons($argcdr);
  my ($mapname, @vals) = ($flat ? $flat->($val) : (map => $val));
  return (
    CALL($mapname => make($rest, $func)),
    (map CONS($_), @vals),
  );
}

my $map_continue = make_Native \&map_continue;
my $lmap_continue = make_Native sub {
  map_continue(@_, sub ($v) {
    panic "lmap_continue given non-list" unless rconsp($v);
    return (lmap => flatten($v));
  });
};

sub map_body ($self, $args, $continue = $map_continue) {
  if (rnilp($self)) {
    return JUST $self;
  }
  my ($car, $cdr) = uncons($self);
  my ($func) = uncons($args);
  return (
    CMB9($func => make($car)),
    SNOC($cdr),
    CONS($func),
    CMB9($continue),
  );
};

method map { map_body($self, $args) }
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

1;
