package XCL0::00::Runtime;

use XCL0::Exporter;
use XCL0::00::Tracing;
use Sub::Util qw(set_subname);

our @EXPORT_OK = qw(
  debug panic assert_rtype
  mkv
  rtype type
  rconsp rnilp rcharsp rboolp rnativep rvalp rvarp rtruep rfalsep
  car cdr
  refp valp val raw deref
  set
  list uncons flatten
  make_scope eval0_00 combine
  wutcol progn salis skvlis
  wrap
  $Scope_Fail
);

sub write_string {
  require XCL0::00::Writer;
  &XCL0::00::Writer::write_string;
}

sub debug (@v) {
  warn join(' ', map write_string($_), @v)."\n";
  $v[-1];
}

sub panic ($str, $v = undef) {
  die join(': ', $str, defined($v) ? write_string($v) : ())."\n";
}

sub mkv ($type, $repr, @v) { [ $type => [ $repr => @v ] ] }

sub type ($v) { $v->[0] }
sub rtype ($v) { $v->[1][0] }

sub rconsp ($v) { rtype($v) eq 'cons' }
sub rnilp ($v) { rtype($v) eq 'nil' }
sub rcharsp ($v) { rtype($v) eq 'chars' }
sub rboolp ($v) { rtype($v) eq 'bool' }
sub rnativep ($v) { rtype($v) eq 'native' }
sub rvalp ($v) { rtype($v) eq 'val' }
sub rvarp ($v) { rtype($v) eq 'var' }

sub assert_rtype ($rtype, $v) {
  panic "Expected rtype $rtype, got" => $v
    unless rtype($v) eq $rtype;
  return $v; # for inline use
}

sub rtruep ($v) {
  assert_rtype bool => $v;
  $v->[1][1]
}

sub rfalsep ($v) { !rtruep($v) }

sub car ($cons, $n = 0) {
  my $targ = ($n ? cdr($cons, $n) : assert_rtype cons => $cons);
  $targ->[1][1];
}

sub cdr ($cons, $n = 1) {
  my $targ = $cons;
  while ($n--) {
    assert_rtype cons => $targ;
    $targ = $targ->[1][2];
  }
  $targ;
}

sub refp ($v) { rtype($v) eq 'val' or rtype($v) eq 'var' }

sub deref ($v) {
  panic "Expected ref, got" => write_string($v) unless refp($v);
  $v->[1][1]
}

sub valp ($v) {
  my $rtype = rtype $v;
  0+!($rtype eq 'cons' or $rtype eq 'nil');
}

sub val ($v) {
  my $r = $v->[1];
  return mkv Fexpr00 => @$r if $r->[0] eq 'Fexpr00';
  panic "Expected val, got" => $v unless valp($v);
  return mkv String00 => @$r if rcharsp $v;
  return mkv Bool00 => @$r if rboolp $v;
  return deref $v;
}

sub raw ($v) {
  panic "Expected val, got" => $v unless valp($v);
  $v->[1][1];
}

sub varp ($v) { 0+!!(rtype($v) eq 'var') }

sub set ($var, $value) {
  assert_rtype var => $var;
  $var->[1][1] = $value;
}

sub list (@list) {
  my $ret = mkv List00 => 'nil';
  foreach my $el (reverse @list) {
    $ret = mkv List00 => cons => $el, $ret;
  }
  return $ret;
}

sub uncons ($cons) {
  assert_rtype cons => $cons;
  @{$cons->[1]}[1,2];
}

sub flatten ($cons) {
  my @ret;
  while ($cons->[1][0] eq 'cons') {
    my ($car, $cdr) = @{$cons->[1]}[1,2];
    push @ret, $car;
    $cons = $cdr;
  }
  return @ret;
}

sub scope_fail ($scope, $args) {
  if (rnilp $args) {
    return state $empty = list();
  }
  list(car $args);
}

our $Scope_Fail = mkv(Fexpr00 => native => \&scope_fail);

sub make_scope ($hash, $next = $Scope_Fail) {
  my $scope_sub = sub ($scope, $args) {
    if (rnilp $args) {
      return state $zero_args = list(
        list(map mkv(String00 => chars => $_), sort keys %$hash),
        list(@{$hash}{sort keys %$hash}),
        $next
      );
    }
    my $first = car $args;
    unless (type($first) eq 'String00') {
      panic "Scope lookup expected string, got" => $first;
    }
    # The do {} is required to prevent the hash lookup being treated as an
    # lvalue and thereby autovivifying the key with an undef value.
    return list($first, $_) for grep defined, do { $hash->{raw($first)} };
    return combine($scope, $next, $args)
  };
  my ($hex) = $scope_sub =~ m/\(0x(\w+)\)/;
  mkv Scope00 => var => mkv Fexpr00 => native =>
    set_subname "SCOPE_${hex}" => $scope_sub;
}

our $event_id = 'A000';

sub combine ($scope, $call, $args) {
  my $res;
  local *T = trace_enter(
    COMB => $event_id++,
    mkv(Call00 => cons => $call => $args),
    \$res
  ) if tracing;
  if (type($call) eq 'Apv00') {
    $args = eval0_00($scope, $args);
    $call = deref $call;
  }
  panic "Can't combine value of type ".type($call) => $call
    unless type($call) eq 'Fexpr00';
  return $res = do {
    my $rtype = rtype($call);
    if ($rtype eq 'native') {
      raw($call)->($scope, $args);
    } elsif ($rtype eq 'cons') {
      combine_fexpr($scope, $call, $args);
    } else {
      panic "Invalid rtype $rtype for fexpr" => $call;
    }
  };
}

sub combine_fexpr ($scope, $fexpr, $args) {
  my ($inscope, $body) = uncons $fexpr;
  my %add = (
    callscope => $scope,
    thisfunc => $fexpr,
    thisargs => $args,
  );
  my $callscope = make_scope(\%add, $inscope);
  eval0_00($callscope, $body);
}

sub lookup ($scope, $v) {
  my $res = combine(
    $scope, deref($scope), list(mkv String00 => chars => raw $v)
  );
  my $cdr = cdr $res;
  if (rnilp $cdr) {
    panic "No such name", $v;
  }
  car $cdr;
}

sub eval0_00 ($scope, $v) {
  my $res;
  local *T = trace_enter(EVAL => $event_id++, $v, \$res) if tracing;
  my $type = type($v);
  return $res = do {
    if ($type eq 'Name00') {
      lookup($scope, $v);
    } elsif ($type eq 'List00') {
      list map eval0_00($scope, $_), flatten $v;
    } elsif ($type eq 'Call00') {
      my ($callp, $args) = uncons $v;
      my $call = eval0_00($scope, $callp);
      combine($scope, $call, $args);
    } else {
      $v;
    }
  };
}

sub wutcol ($scope, $if, $then, $else) {
  my $res = eval0_00 $scope, $if;
  if (rtruep $res) {
    return eval0_00 $scope, $then;
  }
  return eval0_00 $scope, $else;
}

sub progn ($scope, $cons) {
  my $res;
  while (!rnilp $cons) {
    my ($first, $rest) = uncons $cons;
    $res = eval0_00 $scope, $first;
    $cons = $rest;
  }
  return $res;
}

sub salis ($scope, $needle, $alis, $fallback) {
  my $find = raw $needle;
  while (!rnilp $alis) {
    (my $pair, $alis) = uncons $alis;
    return $pair if raw(car($pair)) eq $find;
  }
  return combine($scope, $fallback, list($needle));
}

sub skvlis ($scope, $needle, $klis, $vlis, $fallback) {
  my $find = raw $needle;
  while (!rnilp $klis) {
    (my $key, $klis) = uncons $klis;
    (my $val, $vlis) = uncons $vlis;
    return list($key, $val) if raw($key) eq $find;
  }
  return combine($scope, $fallback, list($needle));
}

sub wrap :prototype($) ($opv_sub) {
  set_subname __WRAPPED__ => sub ($scope, $lstp) {
    my $lst = eval0_00 $scope, $lstp;
    $opv_sub->($scope, $lst)
  }
}

1;
