use NXCL::Test;
use NXCL::TypeFunctions qw(OpDict Native make_List make_String);
use NXCL::JSON;
use JSON::Dumper::Compact qw(jdc);

warn jdc(nxcl2json(OpDict));
warn jdc(nxcl2json(Native));
warn jdc(nxcl2json(make_String("foo")));
warn jdc(nxcl2json(make_List()));
warn jdc(nxcl2json(make_List(make_String("foo"))));

done_testing;
