use NXCL::Test;
use Test2::IPC;
use Child;
use Path::Tiny;

path('lib')->visit(sub ($path, $) {
  return unless $path =~ /\.pm$/ and $path =~ s/^lib\///;
  Child->new(sub {
    try_ok { require $path } "Loaded ok: ${path}";
  })->start->wait;
}, { recurse => 1 });

done_testing;
