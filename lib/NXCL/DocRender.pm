package NXCL::DocRender;

use NXCL::Exporter;

our @EXPORT = qw(render);

sub render ($eval, $code) {
  package NXCL::DocRender::In;
  return eval($eval) // die "Eval failed for ${code} using ${eval}: $@";
}

package NXCL::DocRender::In;

use NXCL::YDump;

sub Read ($data) {
  state $reader = do { require NXCL::Reader; NXCL::Reader->new };
  $reader->parse(script => $data);
}

1;
