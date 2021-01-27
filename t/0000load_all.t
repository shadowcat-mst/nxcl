use NXCL::Test;
use Path::Tiny;

path('lib')->visit(sub ($path, $) {
  return unless $path =~ /\.pm$/ and $path =~ s/^lib\///;
  bail_out unless try_ok { require $path } "Loaded ok: ${path}";
}, { recurse => 1 });

done_testing;
