package NXCL::LvalueFunT;

use NXCL::Utils qw(raw flatten);
use NXCL::ReprTypes qw(DictR);
use NXCL::TypeSyntax;

export make ($call, $assign_via_call) {
  _make DictR ,=> {
    call => $call,
    assign_via_call => $assign_via_call,
  };
}

static new {
  JUST make flatten($args)
}

methodx COMBINE {
  CMB9 raw($self)->{call}, $args
}

methodx ASSIGN_VIA_CALL {
  CMB9 raw($self)->{assign_via_call}, $args
}

1;
