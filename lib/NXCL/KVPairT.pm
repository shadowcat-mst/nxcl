package NXCL::KVPairT;

use NXCL::ReprTypes qw(ConsR);
use NXCL::TypeFunctions qw(
  make_Key make_List just_Native list_Combine
);
use NXCL::Utils qw(uncons);
use NXCL::TypeSyntax;

export make ($k, $v) { _make ConsR ,=> $k, $v }

methodx AS_PLAIN_EXPR {
  my ($kp, $v) = uncons $self;
  my $k = make_Key $kp;
  return (
    CALL(AS_PLAIN_EXPR => make_List($k)),
    SETL('plain_key'),
    CALL(AS_PLAIN_EXPR => make_List($v)),
    USEL(plain_key => 'LIST'),
    CMB9(just_Native \&list_Combine),
  );
}

1;
