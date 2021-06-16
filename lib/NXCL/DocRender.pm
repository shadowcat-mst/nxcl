package NXCL::DocRender;

use NXCL::Exporter;
use NXCL::YDump;

our @EXPORT = qw(render);

sub render ($eval, $code) {
  return eval($eval) // die "Eval failed for ${code} using ${eval}: $@";
}

sub Read ($data) {
  nxcl_require('NXCL::Reader')->new->parse(script => $data);
}

1;
