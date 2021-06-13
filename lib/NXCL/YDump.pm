package NXCL::YDump;

use CPAN::Meta::YAML qw(Dump);
use NXCL::Exporter;

our @EXPORT = qw(ydump);

sub _cook ($type, @parts) {
  my @cooked_parts = map { ref($_) ? __SUB__->(@$_) : $_ } @parts;
  return { $type => (@cooked_parts > 1 ? \@cooked_parts : $cooked_parts[0]) };
}

sub ydump ($data) {
  Dump(_cook(@$data)) =~ s/^---\n//r =~ s/^( *)-/$1 /mgr =~ s/^ *\n//mgr;
}

1;
