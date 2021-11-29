package NXCL::LvalueFunT;

use NXCL::Utils qw(raw);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypePackage;

sub make ($call, $assign_via_call) {
  _make DictR ,=> {
    call => $call,
    assign_via_call => $assign_via_call,
  };
}

export make => \&make;

method combine => sub ($self, $args) {
  CMB9 raw($self)->{call}, $args
};

method assign_via_call => sub ($self, $args) {
  CMB9 raw($self)->{assign_via_call}, $args
};

1;
