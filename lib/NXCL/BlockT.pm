package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw);
use NXCL::TypePackage;

export make => sub ($call) { _make ValR ,=> $call };

method COMBINE => sub ($self, $args) {
 return(
    GCTX(),
    LIST(),
    CALL('scope'),
    LIST(),
    CALL('derive'),
    DOCTX($self, 0, [
      DYNREG('defer'),
      EVAL(raw($self)),
    ])
  );
};

1;
