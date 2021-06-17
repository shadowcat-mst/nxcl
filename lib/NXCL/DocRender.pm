package NXCL::DocRender;

use NXCL::Exporter;
use CPAN::Meta::YAML qw(Load);

our @EXPORT = qw(render);

sub render ($str) {
  die "No metadata block" unless $str =~ s/\A---\n(.*?)---\n+//s;
  my $meta = Load($1);
  my $render = $meta->{'render-block'};
  return $str =~ s/((?:^    .*\n)+)/$1.parse_block($render, $1)/emgr;
}

sub parse_block ($render, $block) {
  my $code = $block =~ s/^    [$ ] //mgr;
  my $y = render_block($render, $code);
  return $y =~ s/^/      /mgr =~ s/\A     /    </r;
}

sub render_block ($render, $code) {
  package NXCL::DocRender::In;
  return eval($render) // die "Eval failed for ${code} using ${render}: $@";
}

package NXCL::DocRender::In;

use NXCL::YDump;

sub Read ($data) {
  state $reader = do { require NXCL::Reader; NXCL::Reader->new };
  $reader->parse(script => $data);
}

1;
