package NXCL::ReprTypes;

use NXCL::Exporter;

use constant our $CONST_SPEC = {
  map {
    my $r = $_;
    ucfirst("${r}R")
      => bless(\$r, "NXCL::_::RType::${\ucfirst($r)}")
  } qw(bool chars bytes nil int val var cons dict native)
};

our @EXPORT = sort keys %{our $CONST_SPEC};

1;
