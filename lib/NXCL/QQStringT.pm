package NXCL::QQStringT;

use NXCL::Utils qw(raw uncons object_is);
use NXCL::TypeFunctions qw(
  make_List empty_List make_Native make_String
  String_Inst Call_Inst Block_Inst
);
use NXCL::ReprTypes qw(ValR);
use NXCL::TypeSyntax;

export list ($list) { _make ValR ,=> $list }

export make (@parts) { list(make_List @parts) }

my $qqeval = make_Native sub ($args) {
  my ($thing) = uncons($args);
  if (object_is $thing, String_Inst) {
    return JUST $thing;
  } elsif (object_is $thing, Call_Inst) {
    return EVAL $thing;
  } elsif (object_is $thing, Block_Inst) {
    return CMB9 $thing, empty_List;
  } else {
    die "WHAT";
  }
};

methodn EVALUATE {
  my $qqparts = raw($self);
  return (
    CALL(map => make_List($qqparts, $qqeval)),
    CONS(make_String('')),
    CALL('concat'),
  );
}

1;
