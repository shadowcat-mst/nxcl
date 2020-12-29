package NXCL::01::Reader::Parser;

use NXCL::Class;

my %is_atomish = (map +($_ => 1), qw(word symbol int string));

my %extract_complex = (
  map +("enter_${_}" => "extract_${_}"), qw(call block list)
);

sub extract_atomish($self, $first, @rest) {
  my ($type, $tok) = @$first;
  return ($first, @rest) if $is_atomish{$type};
  return () unless my $extract = $extract_complex{$type};
  return $self->$extract(@rest);
}

sub extract_compoundish($self, @toks) {
  my ($compound, @toks1) = $self->_extract_compoundish(@toks);
  return () unless @$compound;
  return ([ compound => $compound ], @toks1);
}

sub _extract_compoundish($self, @toks) {
  my @compound;
  while (@toks) {
    last unless (my $found, @toks) = $self->extract_atomish(@toks);
    push @compound, $found;
  }
  return (\@compound, @toks);
}

sub extract_wsish($self, @toks) {
  my $ret = '';
  while (@toks) {
    my ($first, @rest) = @toks;
    my ($type, $tok) = @$first;
    last unless $type eq 'ws' or $type eq 'comment';
    $ret .= $tok;
    @toks = @rest;
  }
  return ($ret, @toks);
}

sub skip_wsish_then($self, $extract, @toks) {
  my (undef, @toks1) = $self->extract_wsish(@toks);
  return $self->$extract(@toks1);
}

sub extract_stmt($self, $args, @toks) {
  my ($stmt, @toks1) = $self->_extract_stmt($args, @toks);
  return unless @$stmt;
  return ($stmt, @toks1);
}

sub _extract_stmt($self, $args, @toks) {
  my @stmt;
  while (@toks) {
    return (\@stmt, @toks) unless my ($compoundish, @toks1)
      = $self->skip_wsish_then(extract_compoundish => @toks);
    push @stmt, $compoundish;
    if (
      $args->{asi}
      and ($self->extract_wsish(@toks1))[0] =~ /\n/
    ) {
      return (\@stmt, @toks1);
    }
    @toks = @toks1;
  }
  return (\@stmt, @toks);
}

my sub extract_one($type) {
  $type
    ? sub ($self, $first, @rest) {
        if ($first->[0] eq $type) {
          return @rest;
        }
        return ();
      }
    : sub ($self, @args) {
        
      }
};

sub extract_list($self, @toks) {
  my ($list, @toks1) = $self->_extract_list(@toks);
  return () unless @$list;
  return ([ list => $list ], @toks1);
}

sub _extract_list($self, @toks) {
  if (my @toks1 = $self->skip_wsish_then(extract_one('end_list'), @toks)) {
    return ([], @toks1);
  }
  if (my @toks1 = $self->skip_wsish_then(extract_one('comma'), @toks)) {
    return $self->_extract_list(@toks1);
  }
  my $attempt = my ($found1, @toks1) = $self->extract_stmt({}, @toks);
  die "Eh? ".$toks[0][0] unless $attempt;
  my ($found2, @toks2) = $self->_extract_list(@toks1);
  return ([ $found1, @$found2 ], @toks2);
}

sub extract_block($self, @toks) { $self->extract_stmt_list(block => @toks) }

sub extract_call($self, @toks) { $self->extract_stmt_list(call => @toks) }

sub extract_toplevel_stmt_list($self, @toks) {
  my ($slist, @toks1) = $self->_extract_stmt_list('', @toks);
  return () unless @$slist;
  return ([ call => $slist ], @toks1);
}

sub extract_stmt_list($self, $type, @toks) {
  my ($slist, @toks1) = $self->_extract_stmt_list("end_${type}", @toks);
  return () unless @$slist;
  return ([ $type, $slist ], @toks1);
}

sub _extract_stmt_list($self, $end_type, @toks) {
  if ($end_type) {
    if (my @toks1 = $self->skip_wsish_then(extract_one($end_type), @toks)) {
      return ([], @toks1);
    }
  } else {
    return [] unless @toks;
  }
  if (my @toks1 = $self->skip_wsish_then(extract_one('semicolon'), @toks)) {
    return $self->_extract_stmt_list($end_type, @toks1);
  }
  my $attempt = my ($found1, @toks1) = $self->extract_stmt({}, @toks);
  die "Eh? ".$toks[0][0] unless $attempt;
  my ($found2, @toks2) = $self->_extract_stmt_list($end_type, @toks1);
  return ([ $found1, @$found2 ], @toks2);
}

1;
