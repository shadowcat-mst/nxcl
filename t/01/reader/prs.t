use NXCL::Test;
use NXCL::DataTest;
use NXCL::01::Reader;
use JSON::Dumper::Compact qw(jdc);

my $r = NXCL::01::Reader->new;

data_test \*DATA, sub ($v) {
  jdc $r->parse_string($v);
};

done_testing;

__DATA__
$ if [ lst.length() > 1 ] {
>   say 'multiple';
> }
< ???
