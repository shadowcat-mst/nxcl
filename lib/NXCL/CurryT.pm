package NXCL::CurryT;

use NXCL::Utils qw(uncons flatten rnilp);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(cons_List make_List make_String empty_List);
use NXCL::TypePackage;

export make => sub ($cmb, @i_args) { cons($cmb, make_List @i_args) };
export cons => \&cons;

sub cons ($cmb, $i_args) { _make ConsR ,=> $cmb, $i_args }

# Should be used as list_to_maybe_Curry($list) later
#export list_to_maybe => sub ($cmb, $i_args) {
#  rnilp($i_args) ? $cmb : cons($cmb, $i_args)
#};

method to_xcl_string => sub ($scope, $, $self, $) {
  state $fmt = make_String('Curry%s');
  return (
    CALL($scope => 'to_xcl_string'
      => make_List(make_List(flatten($self)))),
    SNOC(empty_List),
    CONS($fmt),
    CALL($scope => 'sprintf'),
  );
};

# called args versus implicit args - c_args versus i_args

method combine => sub ($scope, $, $self, $c_args) {
  my ($cmb, $i_args) = uncons($self);
  if (rnilp $c_args) {
    return CMB9 $scope => $cmb => $i_args;
  }
  my $full_args = cons_List(flatten($i_args), $c_args);
  return CMB9 $scope => $cmb => $full_args;
};

1;
