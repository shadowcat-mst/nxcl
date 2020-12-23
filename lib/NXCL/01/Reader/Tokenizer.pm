package NXCL::01::Reader::Tokenizer;

use NXCL::Exporter;

our @EXPORT = qw(tokenize);

my %chars_for_token = (
  ws => " \t\n",
  int => '0123456789',
  word => 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_',
  symbol => (my $symbol_chars = '.!$%&*+-:<=>@\\^|~?'),
  string => "'",
  comma => ",",
  semicolon => ";",
  enter_call => '[',
  enter_list => '(',
  enter_block => '{',
  leave_call => ']',
  leave_list => ')',
  leave_block => '}',
  comment => '#',
);

my %token_matchers = (
  ws => qr'(\s+)',
  word => qr'(\w+)',
  int => qr'([0-9]+)',
  symbol => qr"([${symbol_chars}])",
  comment => qr'(#.*?\n)',
);

my @token_types = keys %chars_for_token;

$token_matchers{$_} ||= qr'^(.)' for @token_types;

my %token_type_for = (
  map {
    my $type = $_;
    map { ($_ => $type) } split '', $chars_for_token{$type}
  } @token_types
);

sub extract_tok($src) {
  my $fst = substr($src, 0, 1);
  my $type = $token_type_for{$fst} // die "No token type for: ${fst}";
  my $rest = ($src =~ s/$token_matchers{$type}//r)
    // die "Match failed for ${type}";
  my $tok_text = $1;
  ([ $type, $tok_text ], $rest);
}

sub tokenize($src) {
  my @tok;
  while ($src) {
    (my $next, $src) = extract_tok($src);
    push @tok, $next;
  }
  \@tok;
}

1;
