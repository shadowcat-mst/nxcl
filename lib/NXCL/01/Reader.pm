package NXCL::01::Reader;

use NXCL::01::Reader::Tokenizer;
use NXCL::01::Reader::Parser;
use NXCL::Class;

lazy _parser => sub ($self) {
  NXCL::01::Reader::Parser->new;
};

sub parse_string ($self, $str) {
  my $toks = tokenize $str;
  # this is assuming no final weirdness but I don't see how it can be a problem
  my ($sl) = $self->_parser->extract_toplevel_stmt_list(@$toks);
  return $sl;
}

1;
