package NXCL::RunTrace;

use NXCL::Package;
use NXCL::YDump;

our $Count = 0;
our $Max;

sub import { $Max = $_[1] if defined $_[1] }

sub NXCL::Runtime::DEBUG { 1 }

use NXCL::ScopeT;
use Hash::Util qw(fieldhash);
fieldhash my %scopes;
BEGIN {
  my $idx = 'A000';
  for ($NXCL::TypeRegistry::TypeInfo{Scope}->exports->{make_Scope}) {
    $_ = do { my $v = $_; sub { my $s = &$v; $scopes{$s} = ++$idx; $s } }
  }
}
use NXCL::Utils qw(uncons mset raw flatten);
use NXCL::TypeFunctions qw(Scope_Inst make_String);
use NXCL::JSON;

sub jsonify ($v) {
  if (mset($v) == Scope_Inst) {
    return [ "Scope (dict) SCOPE_".$scopes{$v} ];
  }
  return nxcl2json($v);
}

sub NXCL::Runtime::DEBUG_WARN ($prog, $kstack) {
  eval {
    my @state = map {
      my ($op, @v) = @$_;
      [ $op => map jsonify(ref() ? $_ : make_String($_)), @v ];
    } ($prog, flatten($kstack));
    warn join('', map ydump($_), @state)."\n";
    1;
  } or do {
    warn ydump([ error => $@ ]); exit 255;
  };
  if (defined $Max) {
    $Count++;
    exit if $Count >= $Max;
  }
}

1;
