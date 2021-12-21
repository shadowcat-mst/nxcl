package NXCL::IntroScopeT;

use NXCL::ReprTypes qw(DictR);
use NXCL::Utils qw(panic flatten uncons raw object_is);
use NXCL::TypeFunctions qw(
  cons_List empty_List
  make_Dict Dict_Inst
);
use NXCL::TypeSyntax;

export make ($scope, $intro_as) {
  _make DictR ,=> {
    scope => $scope,
    intro_as => $intro_as,
  };
}

methodx get_value_for_name {
  return CALL(get_value_for_name
    => cons_List(raw($self)->{scope}, $args)
  );
}

methodx set_value_for_name {
  my ($namep, $vlist) = uncons($args);
  my $intro_as = raw($self)->{intro_as};
  return (
    CALL(new => cons_List($intro_as, $vlist)),
    LIST(raw($self)->{scope}, $namep),
    CALL('set_cell_for_name'),
    DROP(),
    JUST((uncons($vlist))[0])
  );
}

methodx set_cell_for_name {
  return CALL(set_cell_for_name
    => cons_List(raw($self)->{scope}, $args)
  );
}

1;
