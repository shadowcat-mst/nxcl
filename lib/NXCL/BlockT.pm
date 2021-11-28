package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw panic object_is);
use NXCL::TypeFunctions qw(make_List);
use NXCL::TypePackage;

export make => sub ($call) { _make ValR ,=> $call };

method combine => sub ($self, $args) {
  return(
    GCTX(),
    LIST(),
    CALL('scope'),
    LIST(),
    CALL('derive'),
    DOCTX($self, 0, [ EVAL raw($self) ])
  );
};

1;
