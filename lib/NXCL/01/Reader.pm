package NXCL::01::Reader;

use NXCL::Package;
use base qw(Parser::MGC);

sub pattern_comment { qr/#.*?\n/ }

sub expect_just ($self, $expect) {
  local $self->{patterns} = { ws => '(*FAIL)' };
  $self->expect($expect);
}

sub nonempty_sequence_of ($self, @args) {
  my $seq = $self->sequence_of(@args);
  $self->fail unless @$seq;
  $seq;
}

sub parse ($self) { [ script => $self->parse_expr_seq ] }

sub parse_word ($self) {
  [ word => $self->expect_just(qr/[A-Za-z_][A-Za-z_0-9-]*/) ]
}

sub parse_symbol ($self) {
  [ symbol => $self->expect_just(qr'[.!\$%&*+/:<=>@\\^|~?-]+') ]
}

sub parse_uint ($self) {
  [ uint => $self->expect_just(qr/[0-9]+/) ]
}

sub parse_string ($self) {
  my (undef, $str) = $self->expect_just(qr/'(.*?(?<=[^\\])(?:\\\\)*)'/);
  [ string => $str =~ s/\\(['\\])/$1/gr ];
}

sub parse_compound ($self) {
  $self->skip_ws;
  [ compound => $self->nonempty_sequence_of('parse_atomish') ]
}

sub parse_atomish ($self) {
  $self->any_of(
    qw(parse_word parse_symbol parse_uint parse_string
       parse_call parse_block parse_list)
  );
}

sub parse_list ($self) {
  [ list => $self->committed_scope_of('(', 'parse_list_body', ')') ]
}

sub parse_list_body ($self) { $self->list_of(',', 'parse_expr') }

sub parse_call ($self) {
  [ call => $self->committed_scope_of('[', 'parse_expr_seq', ']') ]
}

sub parse_block ($self) {
  [ block => $self->committed_scope_of('{', 'parse_expr_seq', '}') ]
}

sub parse_expr_seq ($self) { $self->list_of(';', 'parse_expr') }

sub parse_expr ($self) {
  [ expr => $self->nonempty_sequence_of('parse_compound') ]
}

1;
