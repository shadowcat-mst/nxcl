package NXCL::Strand;

use NXCL::Class;
use NXCL::Runtime qw(%STEP_FUNC);

sub take_step ($self, $cxs, $ops, $op, @v) {
  die "EMPTY CX STACK" unless @$cxs;
  die "EMPTY OP STACK" unless @$ops;
  die "Unknown op type $op" unless my $step_func = $STEP_FUNC{$op};
  $step_func->($cxs, $ops, @v);
  return;
}

sub run_til_host ($self, $cxs, $ops, $trace_cb) {
  #local our $CURRENT_CXS = $cxs;
  while (1) {
    $trace_cb->($cxs, $ops) if $trace_cb;
    my ($op, @v) = @{pop @$ops};
    return @v if $op eq 'HOST';
    $self->take_step($cxs, $ops, $op, @v);
  }
}

1;
