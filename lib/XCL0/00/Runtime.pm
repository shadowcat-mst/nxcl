package XCL0::00::Runtime;

use Mojo::Base -strict, -signatures;
use XCL0::00::Tracing;
use Sub::Util qw(set_subname);
use Exporter 'import';

our @EXPORT_OK = qw(
  panic assert_rtype
  mkv
  rtype type
  rconsp rnilp rcharsp rboolp rnativep rvalp rvarp rtruep rfalsep
  car cdr
  valp val raw deref
  set
  list uncons flatten
  make_scope eval0_00 combine
  progn
  wrap
);

sub write_string {
  require XCL0::00::Writer;
  &XCL0::00::Writer::write_string;
}

sub panic ($str, $v) {
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
  panic "Expected val, got" => $v unless valp($v);
  my $r = $v->[1];
  return mkv String => $r if rcharsp $v;
  return mkv Bool => $r if rboolp $v;
  return mkv Native => $r if rnativep $v;
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
  return mkv List => 'nil' unless @list;
  my ($first, @rest) = @list;
  mkv 'List', cons => $first, list(@rest);
}

sub uncons ($cons) {
  assert_rtype cons => $cons;
  @{$cons->[1]}[1,2];
}

sub flatten ($cons) {
  return () if rnilp $cons;
  my ($car, $cdr) = uncons $cons;
  return ($car, flatten($cdr));
}

sub scope_fail ($scope, $args) { panic "No such name: ".raw(car $args) }

sub make_scope ($hash, $next = mkv(Native => native => \&scope_fail)) {
  mkv Scope => var => mkv Native => native =>
    set_subname __SCOPE__ => wrap(sub ($scope, $args) {
      my $first = car $args;
      unless (type($first) eq 'String') {
        panic "Scope lookup expected string, got" => $first;
      }
      return $_ for grep defined, $hash->{raw($first)};
      return combine($scope, $next, $args)
    });
}

our $event_id = 'A000';

sub combine ($scope, $call, $args) {
  my $res;
  local *T = trace_enter(
    COMB => $event_id++,
    mkv(Call => cons => $call => $args),
    \$res
  ) if tracing;
  my $type = type($call);
  return $res = do {
    if ($type eq 'Native') {
      raw($call)->($scope, $args);
    } elsif ($type eq 'Fexpr') {
      combine_fexpr($scope, $call, $args);
    } else {
      panic "Can't combine value of type $type" => $call;
    }
  };
}

sub combine_fexpr ($scope, $fexpr, $args) {
  my ($inscope, $body) = uncons $fexpr;
  my %add = (
    scope => $scope,
    thisfunc => $fexpr,
    args => $args,
  );
  my $callscope = make_scope(\%add, $inscope);
  eval0_00($callscope, $body);
}

sub eval0_00 ($scope, $v) {
  my $res;
  local *T = trace_enter(EVAL => $event_id++, $v, \$res) if tracing;
  my $type = type($v);
  return $res = do {
    if ($type eq 'Name') {
      combine($scope, deref($scope), list(mkv String => chars => raw $v));
    } elsif ($type eq 'List') {
      list map eval0_00($scope, $_), flatten $v;
    } elsif ($type eq 'Call') {
      my ($callp, $args) = uncons $v;
      my $call = eval0_00($scope, $callp);
      combine($scope, $call, $args);
    } else {
      $v;
    }
  };
}

sub progn ($scope, $args) {
  my ($first, $rest) = uncons $args;
  my $res = eval0_00 $scope, $first;
  return $res if rnilp $rest;
  progn($scope, $rest);
}

sub wrap :prototype($) ($opv_sub) {
  set_subname __WRAPPED__ => sub ($scope, $lstp) {
    my $lst = eval0_00 $scope, $lstp;
    $opv_sub->($scope, $lst)
  }
}

1;
