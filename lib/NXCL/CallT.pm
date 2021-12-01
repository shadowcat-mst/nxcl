package NXCL::CallT;

use NXCL::Utils qw(panic raw uncons rnilp);
use NXCL::TypeFunctions qw(make_List);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypePackage;

export of_list => \&of_list;

sub of_list ($list) { _make ValR ,=> $list }

export make => sub (@parts) { of_list(make_List @parts) };

method EVALUATE => sub ($self, $args) {
  my $call_list = raw($self);
  panic "Empty call list" if rnilp($call_list);
  my ($first, $rest) = uncons($call_list);
  return (
    EVAL($first),
    (rnilp($rest)
      ? ()
      : (DROP(), EVAL(of_list($rest)))
    )
  );
};

1;
