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

sub _list ($first, @rest) {
  [ List => [ cons =>
    $first,
    (@rest ? _list(@rest) : [ List => [ 'nil' ] ])
  ] ]
}

sub _call (@args) {
  [ Call => _list(@args)->[1] ]
}

sub prs (@tok) {
  my @res;
  while (my $m = shift @tok) {
    my $ret;
    if ($m->[0] eq 'EnterCall') {
      ($ret, @tok) = prs_call(@tok)
    } else {
      $ret = $m;
    }
    push @res, $ret;
  }
  return @res;
}

sub prs_call (@tok) {
  my @res;
  while (my $m = shift @tok) {
    last if $m->[0] eq 'LeaveCall';
    my $ret;
    if ($m->[0] eq 'EnterCall') {
      ($ret, @tok) = prs_call(@tok)
    } else {
      $ret = $m;
    }
    push @res, $ret;
  }
  _call @res;
}

sub parse_string ($string) {
  [ prs tok $string ];
}
