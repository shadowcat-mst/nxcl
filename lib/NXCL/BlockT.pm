package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw);
use NXCL::TypeSyntax;

export make ($call) { _make ValR ,=> $call }

methodn AS_PLAIN_EXPR { return JUST $self }

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
