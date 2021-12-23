package NXCL::LvalueFunT;

use NXCL::Utils qw(raw flatten);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypePackage;

sub make ($call, $assign_via_call) {
  _make DictR ,=> {
    call => $call,
    assign_via_call => $assign_via_call,
  };
}

export make => \&make;

wrap static new => sub ($self, $args) {
  JUST make flatten($args)
};

method COMBINE => sub ($self, $args) {
  CMB9 raw($self)->{call}, $args
};

method ASSIGN_VIA_CALL => sub ($self, $args) {
  CMB9 raw($self)->{assign_via_call}, $args
};

1;