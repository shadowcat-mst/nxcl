package NXCL::Reader;

our $SYMBOL_CHARS = '.!$%&*+-/:<=>@\\^|~?';

our %START = (
  ' ' => 'ws',
  "\t" => 'ws',
  "\n" => 'ws',
  (map +("$_" => 'natural'), 0..9),
  (map +($_ => 'word'), ('a' .. 'z'), ('A' .. 'Z'), '_'),
  (map +($_ => 'symbol'), split '', $SYMBOL_CHARS),
  "'" => 'qstring',
  "," => 'comma',
  ";" => 'semicolon',
  '[' => 'call',
  '(' => 'list',
  '{' => 'block',
  ']' => 'call_end',
  ')' => 'list_end',
  '}' => 'block_end',
  '#' => 'comment',
  # '"' => 'qqstring',
  # '`' => 'blockstring',
);

our %IS_FLUFF = (ws => 1, comment => 1);

our %IS_ATOMSTART = (
  map +($_ => 1),
    qw(qstring natural word symbol list block call)
);

use NXCL::Class;

lazy str => sub { die "WHAT" };

sub extract_char ($self, $char) {
  die "WHAT" unless substr($self->str, 0, 1) eq $char;
  substr($self->{str}, 0, 1) = '';
  return $char;
}

sub extract_expr_seq ($self, $delim) {
  my @seq;
  while (my $type = $self->peek_type) {
    if ($IS_FLUFF{$type} or $type eq $delim) {
      push @seq, $self->${\"parse_${type}"};
    } elsif ($IS_ATOMSTART{$type}) {
      push @seq, $self->parse_expr;
    } else {
      last;
    }
  }
  @seq;
}

sub extract_re ($self, $re) {
  die "WHAT" unless $self->{str} =~ s/^$re//;
  return $&;
}

sub parse ($self, $type, $str) {
  local $self->{str} = $str;
  $self->${\"parse_${type}"};
}

sub parse_script ($self) {
  [ script => $self->extract_expr_seq('semicolon') ];
}

sub parse_expr ($self) {
  my @expr;
  while (my $type = $self->peek_type) {
    if ($IS_FLUFF{$type}) {
      push @expr, $self->${\"parse_${type}"};
    } elsif ($IS_ATOMSTART{$type}) {
      push @expr, $self->parse_compound;
    } else {
      last;
    }
  }
  [ expr => @expr ];
}

sub parse_compound ($self) {
  my @compound;
  while (my $type = $self->peek_type) {
    if ($IS_ATOMSTART{$type}) {
      push @compound, $self->${\"parse_${type}"};
    } else {
      last;
    }
  }
  return [ compound => @compound ];
}

sub parse_ws ($self) {
  [ ws => $self->extract_re(qr/\s+/) ]
}

sub parse_comment ($self) {
  [ comment => $self->extract_re(qr{#.*?\n}) ]
}

sub parse_semicolon ($self) {
  [ semicolon => $self->extract_char(';') ]
}

sub parse_comma ($self) {
  [ comma => $self->extract_char(',') ]
}

sub parse_word ($self) {
  [ word => $self->extract_re(qr/[A-Za-z_][A-Za-z_0-9-]*/) ]
}

sub parse_symbol ($self) {
  [ symbol => $self->extract_re(qr"[${SYMBOL_CHARS}]+") ]
}

sub parse_natural ($self) {
  [ natural => $self->extract_re(qr/[0-9]+/) ]
}

sub parse_qstring ($self) {
  [ qstring => $self->extract_re(qr/'(.*?(?<=[^\\])(?:\\\\)*)'/) ]
}

sub parse_call ($self) {
  $self->parse_delimited_sequence(call => '[', ']', 'semicolon');
}

sub parse_block ($self) {
  $self->parse_delimited_sequence(block => '{', '}', 'semicolon');
}

sub parse_list ($self) {
  $self->parse_delimited_sequence(list => '(', ')', 'comma');
}

sub parse_delimited_sequence ($self, $type, $enter, $leave, $sep) {
  my @contents = ([ "enter_${type}" => $self->extract_char($enter) ]);
  push @contents, $self->extract_expr_seq($sep);
  push @contents, [ "leave_${type}" => $self->extract_char($leave) ];
  return [ $type => @contents ];
}
  
sub peek_type ($self) {
  return unless length($self->str);
  $START{substr($self->str,0,1)} // die "WHAT: ".$self->str;
}

1;
