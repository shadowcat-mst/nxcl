package NXCL::CurryT;

use NXCL::Utils qw(uncons flatten rnilp);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(cons_List make_List make_String empty_List);
use NXCL::TypePackage;

export make => sub ($curried, @i_args) { cons($curried, make_List @i_args) };
export cons => \&cons;

sub cons ($curried, $i_args) { _make ConsR ,=> $curried, $i_args }

method to_xcl_string => sub ($self, $) {
  state $fmt = make_String('Curry%s');
  return (
    CALL('to_xcl_string'
      => make_List(make_List(flatten($self)))),
    LIST($fmt),
    CALL('sprintf'),
  );
};

# called args versus implicit args - c_args versus i_args

method COMBINE => sub ($self, $c_args) {
  my ($curried, $i_args) = uncons($self);
  if (rnilp $c_args) {
    return CMB9 $curried => $i_args;
  }
  my $full_args = cons_List(flatten($i_args), $c_args);
  return CMB9 $curried => $full_args;
};

1;
