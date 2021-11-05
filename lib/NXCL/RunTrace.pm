package NXCL::RunTrace;

use NXCL::Package;
use NXCL::YDump;
use NXCL::OpUtils;

our $Count = 0;
our $Max;

sub import { $Max = $_[1] if defined $_[1] }

{
  use warnings FATAL => 'redefine';
  sub NXCL::Runtime::DEBUG :prototype() { 1 }
}

use NXCL::ScopeT;
use Hash::Util qw(fieldhash);
fieldhash my %scopes;
BEGIN {
  my $idx = 'A000';
  for ($NXCL::TypeRegistry::TypeInfo{Scope}->exports->{make_Scope}) {
    $_ = do { my $v = $_; sub { my $s = &$v; $scopes{$s} = ++$idx; $s } }
  }
  my $v = NXCL::ScopeT->can('make');
  my $wrapped = sub { my $s = &$v; $scopes{$s} = ++$idx; $s };
  no warnings 'redefine';
  *NXCL::ScopeT::make = $wrapped;
}
fieldhash my %op_origins;
BEGIN {
  my $make_op = NXCL::OpUtils->can('make_op');
  my $wrapped = sub {
    my %origin;
    my $level = 2;
    while (1) {
      my ($package)
        = (undef, @origin{qw(filename line sub)})
        = caller($level);
      last unless
        $package eq 'NXCL::TypeMethod'
        or $package eq 'NXCL::MethodUtils';
      ++$level;
    }
    while (1) {
      my $callsub = $origin{callsub} = (caller($level+1))[3];
      last unless $callsub eq 'NXCL::Runtime::take_method_step';
      ++$level;
    }
    if (my $inc_file = { reverse %INC }->{$origin{filename}}) {
      $origin{filename} = $inc_file;
    }
    s/^NXCL::/+/ for @origin{qw(sub callsub)};
    my $op = $make_op->(@_);
    $op_origins{$op} = \%origin;
    return $op;
  };
  no warnings 'redefine';
  *NXCL::OpUtils::make_op = $wrapped;
}
use NXCL::Utils qw(uncons object_is raw flatten);
use NXCL::TypeFunctions qw(Scope_Inst make_String);
use NXCL::JSON;

sub jsonify ($v) {
  if (object_is $v, Scope_Inst) {
    return [ "Scope (dict) SCOPE_".$scopes{$v} ];
  }
  return nxcl2json($v);
}

sub NXCL::Runtime::DEBUG_WARN ($cxs, $opq) {
  if (my $origin = $op_origins{$opq->[-1]}) {
    warn join(' ', '#', @{$origin}{qw(callsub sub filename line)})."\n";
  }
  eval {
    my ($pst, @stst) = map {
      my ($op, @v) = @$_;
      [ $op => map jsonify(ref() ? $_ : make_String($_//'NULL')), @v ];
    } reverse @$opq;
    warn join('',
      ydump($pst) =~ s/^/  /mgr,
      map ydump($_) =~ s/^/+ /mgr, @stst
    )."\n";
    1;
  } or do {
    warn ydump([ debug_render_error => $@ ]);
    warn "aborting from DEBUG_WARN\n";
    exit 255;
  };
  if (defined $Max) {
    $Count++;
    exit if $Count >= $Max;
  }
}

1;
