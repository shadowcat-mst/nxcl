package NXCL::CompoundT;

use NXCL::Utils qw(flatten object_is);
use NXCL::TypeFunctions qw(List_Inst make_List cons_List);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeSyntax;

export make ($first, @rest) { _make ConsR ,=> $first, make_List(@rest) }

methodx EVALUATE {
  my ($first, @rest) = flatten $self;
  my @exp_rest = map +(object_is($_, List_Inst) ? $_ : make_List($_)), @rest;
  return (
    EVAL($first),
    map CMB6($_), @exp_rest
  );
}

methodx ASSIGN_VALUE {
  my ($first, @rest) = flatten $self;
  my @exp_rest = map +(object_is($_, List_Inst) ? $_ : make_List($_)), @rest;
  my $call_args = pop @exp_rest;
  return (
    EVAL($first),
    (map CMB6($_), @exp_rest),
    SNOC(cons_List($call_args, $args)),
    CALL('ASSIGN_VIA_CALL'),
  );
}

1;
