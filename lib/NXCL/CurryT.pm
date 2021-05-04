package NXCL::CurryT;

use NXCL::Utils qw(uncons flatten rnilp);
use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(cons_List make_List);
use NXCL::TypePackage;

export make => sub ($cmb, @i_args) { cons($cmb, make_List @i_args) };
export cons => \&cons;

sub cons ($cmb, $i_args) { _make ConsR ,=> $cmb, $i_args }

# called args versus implicit args - c_args versus i_args

method combine => sub ($scope, $, $self, $c_args) {
  my ($cmb, $i_args) = uncons($self);
  if (rnilp $c_args) {
    return (
      [ CMB9 => $scope => $cmb => $i_args ],
    );
  }
  my $full_args = cons_List(flatten($i_args), $c_args);
  return (
    [ CMB9 => $scope => $cmb => $full_args ],
  );
};

1;
