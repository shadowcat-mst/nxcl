package NXCL::YDump;

use CPAN::Meta::YAML qw(Dump);
use Safe::Isa;
use NXCL::Exporter;

our @EXPORT = qw(ydump);

sub _cook ($type = '+++ EMPTY +++', @parts) {
  my @cooked_parts = map {
    if ($_->$_isa('JSON::PP::Boolean')) {
      ($_ ? 'true' : 'false')
    } elsif (ref($_) eq 'ARRAY') {
      __SUB__->(@$_)
    } elsif (ref($_) eq 'HASH') {
      my %h = %{$_};
      +{ map +($_ => __SUB__->(@{$h{$_}})), sort keys %h }
    } else {
      $_
    }
  } @parts;
  return { $type => (@cooked_parts > 1 ? \@cooked_parts : $cooked_parts[0]) };
}

sub ydump ($data) {
  Dump(_cook(@$data)) =~ s/^---\n//r =~ s/^( *)-/$1 /mgr =~ s/^ *\n//mgr;
}

1;
