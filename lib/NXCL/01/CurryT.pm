package NXCL::01::CurryT;

use NXCL::01::Utils qw(uncons flatten rnilp);
use NXCL::01::ReprTypes qw(ConsR);
use NXCL::01::TypeFunctions qw(cons_List);
use NXCL::01::TypeExporter;

export make => sub ($combiner, $i_args) { _make ConsR ,=> $combiner, $i_args };

# called args versus implicit args - c_args versus i_args

method combine => sub ($scope, $cmb, $self, $c_args, $kstack) {
  my ($combine, $i_args) = uncons($self);
  if (rnilp $c_args) {
    return (
      [ CMB9 => $scope => $combine => $i_args ],
      $kstack
    );
  }
  my $full_args = cons_List(flatten($i_args), $c_args);
  return (
    [ CMB9 => $scope => $combine => $full_args ],
    $kstack
  );
};

1;
