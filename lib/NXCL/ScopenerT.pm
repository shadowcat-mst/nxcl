package NXCL::ScopenerT;

use NXCL::Utils qw(uncons raw panic rnilp flatten);
use NXCL::OpUtils;
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeFunctions qw(make_List make_IntroScope);
use NXCL::TypeSyntax;

export make ($type) { _make ValR ,=> $type }

methodx ASSIGN_VIA_CALL {
  my ($targetp, $value) = flatten($args);
  my ($target) = uncons($targetp);
  my $type = raw($self);
  return (
    GCTX(),
    LIST(),
    CALL('scope'),
    SNOC(make_List($type)),
    CALL('introscope'),
    DOCTX($self, [
      LIST($target, $value),
      CALL('ASSIGN_VALUE'),
    ])
  );
}

1;
