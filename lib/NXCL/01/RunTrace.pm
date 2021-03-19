package NXCL::01::RunTrace;

use NXCL::Package;
use JSON::Dumper::Compact qw(jdc);

our $Count = 0;
our $Max;

sub import { $Max = $_[1] if defined $_[1] }

sub NXCL::01::Runtime::DEBUG { 1 }

use NXCL::01::Utils qw(uncons mset raw);
use NXCL::01::TypeFunctions qw(Scope_Inst);
use NXCL::01::JSON;

sub jsonify ($v) {
  if (mset($v) == Scope_Inst) {
    return [ Scope => 0+raw($v) ];
  }
  return nxcl2json($v);
}

sub NXCL::01::Runtime::DEBUG_WARN ($prog, $kstack) {
  my @state;
  #while ($prog) {
    my ($op, @v) = @$prog;
    push @state, [ $op => map jsonify($_), @v ];
  #  ($prog, $kstack) = uncons($kstack);
  #}
  #warn jdc(\@state);
  warn jdc($state[0]);
  if (defined $Max) {
    $Count++;
    exit if $Count >= $Max;
  }
}

1;
