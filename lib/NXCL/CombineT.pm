package NXCL::CombineT;

use NXCL::Utils qw(uncons);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(make_List cons_List);
use NXCL::TypePackage;

export make => sub ($call, @args) { _make ConsR ,=> $call, make_List @args };
export cons => sub ($call, $args) { _make ConsR ,=> $call, $args };
export list => sub ($list) { _make ConsR ,=> uncons($list) };

method evaluate => sub ($self, $args) {
  my ($call, $call_args) = uncons $self;
  return (
    EVAL($call),
    CMB6($call_args),
  );
};

wrap method assign_value => sub ($self, $args) {
  my ($call, $call_args) = uncons $self;
  return (
    EVAL($call),
    SNOC(cons_List($call_args, $args)),
    CALL('assign_via_call'),
  );
};

1;
