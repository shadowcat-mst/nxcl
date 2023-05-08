package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw rconsp uncons);
use NXCL::TypeFunctions qw(make_List make_Name make_Val just_Native);
use NXCL::TypeSyntax;

export make ($call) { _make ValR ,=> $call }

methodx AS_PLAIN_EXPR {
  return (
    CALL(AS_PLAIN_EXPR => make_List raw($self)),
    CMB9(just_Native \&make),
  );
}

method COMBINE {
  my @this = (
    rconsp($args)
      ? (
          SNOC(make_List make_Name('this'), make_Val((uncons $args)[0])),
          CALL('set_cell_for_name'),
        )
      : ()
  );
  return (
    GCTX(),
    LIST(),
    CALL('scope'),
    LIST(),
    CALL('derive'),
    @this,
    DOCTX($self, [
      DYNREG('defer'),
      EVAL(raw($self)),
    ])
  );
}

1;
