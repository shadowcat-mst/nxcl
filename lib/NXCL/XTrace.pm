package NXCL::XTrace;

use NXCL::Package;
use NXCL::Environment;
use NXCL::ValueBuilders;

sub import {
  $NXCL::Environment::DEFAULT_TRACE_CB = \&DEBUG_WARN;
}

our $Trace_Env = NXCL::Environment->new(trace_cb => undef);

sub DEBUG_WARN ($cxs, $ops) {
  my $next_op = $ops->[-1];
  warn join(' ',
    map +(
      ref()
        ? $Trace_Env->eval(Cmb MCall to_xcl_string => $_)->xcl_raw_value
        : $_//'NULL'
    ), @$next_op
  )."\n";
}

1;
