package NXCL::00::Tracing;

use NXCL::Exporter;
use Scope::Guard;

our @EXPORT = qw(*T tracing trace_enter trace_stack);

use constant tracing => 0+!!$ENV{NXCL_00_TRACING};

our %T;

sub write_string {
  require NXCL::00::Writer;
  &NXCL::00::Writer::write_string;
}

sub trace_enter ($type, $id, $val, $retref) {
  warn "${id} ENTER ${type} { ${\write_string($val)}\n";
  return {
    %T,
    stack => [ @{$T{stack}||[]}, [ $type, $id, $val ] ],
    on_leave => Scope::Guard->new(sub {
      if (defined $$retref) {
        warn "${id} LEAVE ${type} } ${\write_string($$retref)}\n";
      } else {
        warn "${id} ABEND ${type} } ${\write_string($val)}\n";
      }
    }),
  };
}

sub trace_stack () { @{$T{stack}||[]} }

1;
