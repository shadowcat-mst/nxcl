package XCL0::00::Parser;

use Mojo::Base -strict, -signatures;
use Exporter 'import';

our @EXPORT_OK = qw(parse_string);

sub _tok ($str) {
  return () unless length $str;
  my $tok;
  local $_ = $str;
  s/^\s+//;
  $tok = do {
    if (/^[A-Za-z_]/) {
      s/^([A-Za-z_\-?]+)// or die;
      [ Name => [ string => $1 ] ];
    } elsif (/^'/) {
      s{'((?:[^'\\\\]+|\\\\.)*)'}{} or die;
      [ String => [ string => $1 ] ];
    } elsif (s/^\[//) {
      [ EnterCall => [ 'nil' ] ];
    } elsif (s/^\]//) {
      [ LeaveCall => [ 'nil' ] ];
    } elsif (s/^;//) {
      [ SemiColon => [ 'nil' ] ];
    } else {
      die;
    }
  };
  ($tok, $_);
}

sub tok ($str) {
  my @tok;
  while ($str) {
    (my $tok, $str) = _tok $str;
    push @tok, $tok;
  }
  @tok;
}

sub prs (@tok) {
  return () unless @tok;
  my ($first, @rest) = @tok;
  if ($first->[0] eq 'EnterCall') {
    prs_call([], @rest);
  } else {
    ($first, prs(@rest))
  }
}

sub _list ($first, @rest) {
  [ List => [ cons =>
    $first,
    (@rest ? _list(@rest) : [ List => [ 'nil' ] ])
  ] ]
}

sub _call (@args) {
  [ Call => _list(@args)->[1] ]
}

sub prs_call ($acc, @tok) {
  my ($first, @rest) = @tok;
  if ($first->[0] eq 'LeaveCall') {
    (_call(@$acc), prs @rest);
  } else {
    prs_call([ @$acc, $first ], @rest);
  }
}

sub parse_string ($string) {
  [ prs tok $string ];
}
