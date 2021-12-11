package NXCL::CurryT;

use NXCL::Utils qw(uncons flatten rnilp);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(cons_List make_List make_String empty_List);
use NXCL::TypeSyntax;

export make ($curried, @i_args) { cons($curried, make_List @i_args) }
export cons ($curried, $i_args) { _make ConsR ,=> $curried, $i_args }

methodn to_xcl_string {
  state $fmt = make_String('Curry%s');
  return (
    CALL('to_xcl_string'
      => make_List(make_List(flatten($self)))),
    LIST($fmt),
    CALL('sprintf'),
  );
}

# called args versus implicit args - args versus i_args

methodx COMBINE {
  my ($curried, $i_args) = uncons($self);
  if (rnilp $args) {
    return CMB9 $curried => $i_args;
  }
  my $full_args = cons_List(flatten($i_args), $args);
  return CMB9 $curried => $full_args;
}

1;
