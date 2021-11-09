package NXCL::BlockT;

use NXCL::ReprTypes qw(ValR);
use NXCL::Utils qw(raw panic object_is);
use NXCL::TypeFunctions qw(make_Scope make_OpDict OpDict_Inst);
use NXCL::TypePackage;

export make => sub ($call) { _make ValR ,=> $call };

method combine => sub ($scope, $cmb, $self, $args) {
  my $store = raw($scope);
  panic 'NYI' unless object_is $store, OpDict_Inst;
  my $block_scope = make_Scope(make_OpDict({ %{raw($store)} }));
  my $block_body = raw($self);
  return DOCTX($block_body, $block_scope, [ EVAL $block_body ]);
};

1;
