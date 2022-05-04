package NXCL::Reader;

our $SYMBOL_CHARS = '.!$%&:<=>@\\^|~?*/+-'; # - last to avoid creating a range

our %START = (
  ' ' => 'ws',
  "\t" => 'ws',
  "\n" => 'ws',
  (map +("$_" => 'numeric'), 0..9),
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
  '"' => 'qqstring',
  # '`' => 'blockstring',
);

our %IS_FLUFF = (ws => 1, comment => 1);

our %IS_ATOMSTART = (
  map +($_ => 1),
    qw(qstring qqstring numeric word symbol list block call)
);

use NXCL::Class;

sub _peek_type ($self) {
  return unless length($self->{str});
  $START{substr($self->{str},0,1)} // die "WHAT: ".$self->{str};
}

sub _extract_char ($self, $char) {
  die "WHAT" unless substr($self->{str}, 0, 1) eq $char;
  substr($self->{str}, 0, 1) = '';
  return $char;
}

sub _extract_expr_seq ($self, $delim) {
  my @seq;
  my $autoterm = 0+($delim eq 'semicolon');
  while (my $type = $self->_peek_type) {
    if ($IS_FLUFF{$type} or $type eq $delim) {
      push @seq, $self->_parse($type);
    } elsif ($IS_ATOMSTART{$type}) {
      push @seq, my $expr = $self->_parse(expr => $autoterm);
      push @seq, pop @$expr while $IS_FLUFF{$expr->[-1][0]};
    } else {
      last;
    }
  }
  @seq;
}

sub _extract_re ($self, $re) {
  die "WHAT" unless $self->{str} =~ s/^$re//;
  return $&;
}

our $ANON = 'A000';

sub parse ($self, $type, $str, $file = 'anon:'.++$ANON) {
  local $self->{str} = local $self->{full_str} = $str;
  local $self->{file} = $file;
  local $self->{start} = 0;
  $self->_parse($type);
}

sub _parse ($self, $type, @args) {
  local $self->{outer_start} = my $start = $self->{start};
  my $orig_str = $self->{str};
  my @parsed = $self->${\"_parse_${type}"}(@args);
  my $consumed = length($orig_str) - length($self->{str});
  my $meta = {
    file => $self->{file},
    contents => $self->{full_str},
    start => $self->{outer_start},
    end => $start += $consumed,
  };
  $self->{start} = $start;
  [ $type, $meta, @parsed ];
}

sub _parse_script ($self) {
  $self->_extract_expr_seq('semicolon')
}

sub _parse_expr ($self, $autoterm) {
  my @expr;
  my $was_block = 0;
  while (my $type = $self->_peek_type) {
    if ($IS_FLUFF{$type}) {
      push @expr, $self->_parse($type);
      last if $autoterm and $was_block and $expr[-1][2] =~ /\n/;
    } elsif ($IS_ATOMSTART{$type}) {
      $was_block = 0+($type eq 'block');
      push @expr, $self->_parse('compound');
    } else {
      last;
    }
  }
  @expr;
}

sub _parse_compound ($self) {
  my @compound;
  while (my $type = $self->_peek_type) {
    if ($IS_ATOMSTART{$type}) {
      push @compound, $self->_parse($type);
    } else {
      last;
    }
  }
  @compound;
}

sub _parse_ws ($self) {
  $self->_extract_re(qr/\s+/)
}

sub _parse_comment ($self) {
  $self->_extract_re(qr{#.*?\n})
}

sub _parse_semicolon ($self) {
  $self->_extract_char(';')
}

sub _parse_comma ($self) {
  $self->_extract_char(',')
}

sub _parse_word ($self) {
  $self->_extract_re(qr/[A-Za-z_][A-Za-z_0-9-]*/)
}

sub _parse_symbol ($self) {
  $self->_extract_re(qr"[\Q${SYMBOL_CHARS}\E]+")
}

sub _parse_numeric ($self) {
  $self->_extract_re(qr/[0-9]+(?:\.[0-9]+)?/)
}

sub _parse_qstring ($self) {
  $self->_extract_re(qr/'(.*?(?<=[^\\])(?:\\\\)*)'/)
}

sub _parse_call ($self) {
  $self->_parse_delimited_sequence(call => '[', ']', 'semicolon');
}

sub _parse_block ($self) {
  $self->_parse_delimited_sequence(block => '{', '}', 'semicolon');
}

sub _parse_list ($self) {
  $self->_parse_delimited_sequence(list => '(', ')', 'comma');
}

sub _parse_delimited_sequence ($self, $type, $enter, $leave, $sep) {
  my @contents = ([ "enter_${type}" => {}, $self->_extract_char($enter) ]);
  push @contents, $self->_extract_expr_seq($sep);
  push @contents, [ "leave_${type}" => {}, $self->_extract_char($leave) ];
  @contents;
}

sub _parse_qqstring ($self) {
  $self->_extract_char('"');
  my @parts;
  while (1) {
    die "WHAT" unless $self->{str} =~ s/^((?:.+?(?<!\\))?(?:\\\\)*)(\$|")//;
    my ($string_part, $next) = ($1, $2);
    push @parts, [ qstring => {}, $string_part ];
    return [ qqstring => {}, @parts ] if $next eq '"';
    my $type = $self->_peek_type;
    die "WHAT" unless $type eq 'call' or $type eq 'block';
    push @parts, $self->${\"_parse_${type}"};
  }
}

1;
