package XCL0::00::Runtime;

use Mojo::Base -base, -signatures;
use Exporter 'import';

our @EXPORT_OK = qw(
  mkv
  typ type
  rconsp rnilp rcharsp rboolp rnativep rvalp rvarp
  car cdr
  valp val raw
  set
  list uncons flatten
  make_scope
  progn
  wrap
);

sub mkv ($type, $repr, @v) { [ $type => [ $repr => @v ] ] }

sub typ ($v) { $v->[1][0] }

sub rconsp ($v) { typ($v) eq 'cons' }
sub rnilp ($v) { typ($v) eq 'nil' }
sub rcharsp ($v) { typ($v) eq 'chars' }
sub rboolp ($v) { typ($v) eq 'bool' }
sub rnativep ($v) { typ($v) eq 'native' }
sub rvalp ($v) { typ($v) eq 'val' }
sub rvarp ($v) { typ($v) eq 'var' }

sub rtruep ($v) {
  die unless typ($v) eq 'bool';
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

sub refp ($v) { typ($v) eq 'val' or typ($v) eq 'var' }

sub deref ($v) {
  die unless refp($v);
  $v->[1][1]
}

sub valp ($v) {
  my $typ = typ $v;
  0+!($typ eq 'cons' or $typ eq 'nil');
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

sub varp ($v) { 0+!!(typ($v) eq 'var') }

sub set ($var, $value) {
  die unless typ($var) eq 'var';
  $var->[1][1] = $value;
}

sub list ($first, @rest) {
  mkv 'List', val => $first, (@rest ? list(@rest) : mkv 'List', 'nil')
}

sub type ($v) { $v->[0] }

sub uncons ($cons) {
  die unless typ($cons) eq 'cons';
  @{$cons->[1]}[1,2];
}

sub flatten ($cons) {
  return () if rnilp $cons;
  my ($car, $cdr) = uncons $cons;
  return ($car, flatten($cdr));
}

sub make_scope ($hash, $next = sub { die }) {
  mkv Native => native => sub ($scope, $args) {
    die unless rcharsp(my $first = car $args);
    $hash->(raw $first) // combine($scope, $next, $args)
  };
}

sub combine ($scope, $call, $args) {
  my $type = typ($call);
  return $call->[1][1]->($scope, $args) if $type eq 'Native';
  die unless $type eq 'Fexpr';
  combine_fexpr($scope, $call, $args);
}

sub combine_fexpr ($scope, $fexpr, $args) {
  my ($inscope, $body) = uncons $fexpr;
  my %add = (
    scope => $scope,
    thisfunc => $fexpr,
    args => $args,
  );
  my $callscope = make_scope(\%add, $inscope);
  eval_inscope($callscope, $body);
}

sub eval_inscope ($scope, $v) {
  my $type = type($v);
  return combine($scope, $scope, list($v)) if $type eq 'Name';
  if ($type eq 'List') {
    return mkv List => (
      rnilp $v
        ? 'nil'
        : (cons => map +(eval_inscope($scope, $_))[1], uncons $v)
    );
  }
  if ($type eq 'Call') {
    my ($callp, $args) = uncons $v;
    my ($scope, $call) = eval_inscope($scope, $callp);
    return combine($scope, $call, $args);
  }
  return ($scope, $v);
}

sub progn ($scope, $args) {
  my ($first, $rest) = uncons $args;
  my ($next_scope, $res) = eval_inscope $scope, $first;
  return ($next_scope, $res) if rnilp $rest;
  progn($next_scope, $rest);
}

sub wrap ($opv_sub) {
  sub ($scope, $lstp) {
    my ($next_scope, $lst) = eval_inscope $scope, $lstp;
    $opv_sub->($next_scope, $lst)
  }
}

1;
