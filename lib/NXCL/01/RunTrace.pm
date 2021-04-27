package NXCL::01::RunTrace;

use NXCL::Package;
use JSON::Dumper::Compact;

our $jdc = JSON::Dumper::Compact->new; # (max_width => 160);

our $Count = 0;
our $Max;

sub import { $Max = $_[1] if defined $_[1] }

sub NXCL::01::Runtime::DEBUG { 1 }

use NXCL::01::ScopeT;
use Hash::Util qw(fieldhash);
fieldhash my %scopes;
BEGIN {
  my $idx = 'A000';
  for ($NXCL::01::TypeRegistry::TypeInfo{Scope}->exports->{make_Scope}) {
    $_ = do { my $v = $_; sub { my $s = &$v; $scopes{$s} = ++$idx; $s } }
  }
}
use NXCL::01::Utils qw(uncons mset raw flatten);
use NXCL::01::TypeFunctions qw(Scope_Inst);
use NXCL::01::JSON;

sub jsonify ($v) {
  if (mset($v) == Scope_Inst) {
    return [ "Scope (dict) SCOPE_".$scopes{$v} ];
  }
  return nxcl2json($v);
}

sub NXCL::01::Runtime::DEBUG_WARN ($prog, $kstack) {
  my @state = map {
    my ($op, @v) = @$_;
    [ $op => map jsonify($_), @v ];
  } ($prog, flatten($kstack));
  warn $jdc->dump(\@state);
  if (defined $Max) {
    $Count++;
    exit if $Count >= $Max;
  }
}

1;
