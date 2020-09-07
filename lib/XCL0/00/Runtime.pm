use Mojo::Base -base, -signatures;

sub mkv ($type, $repr, @v) { [ $type => [ $repr => @v ] ] }

sub typ ($v) { $v->[1][0] }

sub rconsp ($v) { typ($v) eq 'cons' }

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

sub valp ($v) {
  my $typ = typ $v;
  return 0 if $typ eq 'cons' or $typ eq 'nil';
  return 1;
}

sub val ($v) {
  die unless valp $v;
  my $typ = typ $v;
  my $r = $v->[1];
  return mkv String => $r if $typ eq 'chars';
  return mkv Bool => $r if $typ eq 'bool';
  return mkv Native => $r if $typ eq 'native';
  return $r if $typ eq 'val' or $typ eq 'var';
  die "NOTREACHED";
}

sub raw ($v) {
  die unless valp $v;
  $v->[1][1];
}

sub set ($var, $value) {
  die unless typ($var) eq 'var';
  $var->[1][1] = $value;
}

sub list ($first, @rest) {
  mkv 'List', val => $first, (@rest ? list(@rest) : mkv 'List', 'nil')
}

sub type ($v) { $v->[0] }

sub rnilp ($v) { typ($v) eq 'nil' }
sub rstringp ($v) { typ($v) eq 'string' }

sub uncons ($cons) {
  die unless typ $cons eq 'cons';
  @{$cons->[1]}[1,2];
}

sub make_scope ($hash, $next = sub { die }) {
  mkv Native => native => sub ($scope, $args) {
    die unless rstringp(my $first = car $args);
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
  return $v unless type($v) eq 'Call';
  my ($callp, $args) = uncons $v;
  my $call = eval_inscope($scope, $callp);
  combine($scope, $call, $args);
}

sub progn ($scope, $args) {
  my ($first, $rest) = uncons $args;
  my $res = eval_inscope $scope, $first;
  return $res if rnilp $rest;
  progn($scope, $rest);
}
