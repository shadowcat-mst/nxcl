package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw);
use NXCL::TypeFunctions qw(make_List just_Native);
use NXCL::TypeSyntax;

export make ($call) { _make ValR ,=> $call }

methodn AS_PLAIN_EXPR {
  return (
    CALL(AS_PLAIN_EXPR => make_List raw($self)),
    CMB9(just_Native \&make),
  );
}

methodn COMBINE {
 return(
    GCTX(),
    LIST(),
    CALL('scope'),
    LIST(),
    CALL('derive'),
    DOCTX($self, [
      DYNREG('defer'),
      EVAL(raw($self)),
    ])
  );
}

1;
