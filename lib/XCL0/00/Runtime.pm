package XCL0::00::Runtime;

use Mojo::Base -base, -signatures;
use XCL0::00::Tracing;
use Exporter 'import';

our @EXPORT_OK = qw(
  mkv
  rtype type
  rconsp rnilp rcharsp rboolp rnativep rvalp rvarp rtruep rfalsep
  car cdr
  valp val raw deref
  set
  list uncons flatten
  make_scope eval_inscope combine
  progn
  wrap
);

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

sub rtruep ($v) {
  die unless rtype($v) eq 'bool';
  $v->[1][1]
}

sub rfalsep ($v) { !rtruep($v) }

sub car ($cons, $n = 0) {
  my $targ = ($n ? cdr($cons, $n) : $cons);
  die unless rconsp $targ;
  $targ->[1][1];
}

sub cdr ($cons, $n = 1) {
  my $targ = $cons;
  while ($n--) {
    die unless rconsp $targ;
    $targ = $targ->[1][2];
  }
  $targ;
}

sub refp ($v) { rtype($v) eq 'val' or rtype($v) eq 'var' }

sub deref ($v) {
  die unless refp($v);
  $v->[1][1]
}

sub valp ($v) {
  my $rtype = rtype $v;
  0+!($rtype eq 'cons' or $rtype eq 'nil');
}

sub val ($v) {
  die unless valp $v;
  my $r = $v->[1];
  return mkv String => $r if rcharsp $v;
  return mkv Bool => $r if rboolp $v;
  return mkv Native => $r if rnativep $v;
  return deref $v;
}

sub raw ($v) {
  die unless valp $v;
  $v->[1][1];
}

sub varp ($v) { 0+!!(rtype($v) eq 'var') }

sub set ($var, $value) {
  die unless rtype($var) eq 'var';
  $var->[1][1] = $value;
}

sub list (@list) {
  return mkv List => 'nil' unless @list;
  my ($first, @rest) = @list;
  mkv 'List', cons => $first, list(@rest);
}

sub uncons ($cons) {
  die unless rtype($cons) eq 'cons';
  @{$cons->[1]}[1,2];
}

sub flatten ($cons) {
  return () if rnilp $cons;
  my ($car, $cdr) = uncons $cons;
  return ($car, flatten($cdr));
}

sub scope_fail ($scope, $args) { die "No such name: ".raw(car $args) }

sub make_scope ($hash, $next = mkv(Native => native => \&scope_fail)) {
  mkv Scope => var => mkv Native => native => sub ($scope, $args) {
    my $first = car $args;
    unless (rcharsp($first)) {
      die "Scope lookup unexpectedly called with argument of type ".type($first);
    }
    $hash->{raw($first)} // combine($scope, $next, $args)
  }
}

our $event_id = 'A000';

sub combine ($scope, $call, $args) {
  my $res;
  local *T = trace_enter(COMB => $event_id++, $args, \$res) if tracing;
  my $type = type($call);
  return $res = do {
    if ($type eq 'Native') {
      raw($call)->($scope, $args);
    } elsif ($type eq 'Fexpr') {
      combine_fexpr($scope, $call, $args);
    } else {
      die "Can't combine: $type";
    }
  };
}

sub combine_fexpr ($scope, $fexpr, $args) {
  my ($inscope, $body) = uncons $fexpr;
  die "Not a scope: $_" for grep $_ ne 'Scope', type($inscope);
  my %add = (
    scope => $scope,
    thisfunc => $fexpr,
    args => $args,
  );
  my $callscope = make_scope(\%add, deref $inscope);
  eval_inscope($callscope, $body);
}

sub eval_inscope ($scope, $v) {
  my $res;
  local *T = trace_enter(EVAL => $event_id++, $v, \$res) if tracing;
  my $type = type($v);
  return $res = do {
    if ($type eq 'Name') {
      combine($scope, deref($scope), list(mkv String => chars => raw $v));
    } elsif ($type eq 'List') {
      list map eval_inscope($scope, $_), flatten $v;
    } elsif ($type eq 'Call') {
      my ($callp, $args) = uncons $v;
      my $call = eval_inscope($scope, $callp);
      combine($scope, $call, $args);
    } else {
      $v;
    }
  };
}

sub progn ($scope, $args) {
  my ($first, $rest) = uncons $args;
  my $res = eval_inscope $scope, $first;
  return $res if rnilp $rest;
  progn($scope, $rest);
}

sub wrap :prototype($) ($opv_sub) {
  sub ($scope, $lstp) {
    my $lst = eval_inscope $scope, $lstp;
    $opv_sub->($scope, $lst)
  }
}

1;
