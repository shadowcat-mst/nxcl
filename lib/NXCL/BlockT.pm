package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw panic object_is);
use NXCL::TypeFunctions qw(make_List);
use NXCL::TypePackage;

export make => sub ($call) { _make ValR ,=> $call };

method combine => sub ($scope, $self, $args) {
  return(
    CALL(derive => make_List($scope)),
    DOCTX($self, 0, [ EVAL raw($self) ])
  );
};

1;
