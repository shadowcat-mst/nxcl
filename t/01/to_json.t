use NXCL::Test;
use NXCL::01::TypeFunctions qw(OpDict Native);
use NXCL::01::JSON;
use JSON::Dumper::Compact qw(jdc);

warn jdc(nxcl2json(OpDict));
warn jdc(nxcl2json(Native));

done_testing;
