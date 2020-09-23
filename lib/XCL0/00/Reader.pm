package XCL0::00::Reader;

use Mojo::Base -strict, -signatures;
use Exporter 'import';

our @EXPORT_OK = qw(read_string);

sub _tok ($str) {
  return () unless length $str;
  my $tok;
  local $_ = $str;
  s/^\s+//;
  $tok = do {
    if (/^[A-Za-z_]/) {
      s/^([A-Za-z_\-?]+)// or die;
      [ Name => [ chars => $1 ] ];
    } elsif (/^'/) {
      s{'((?:[^'\\\\]+|\\\\.)*)'}{} or die;
      [ String => [ chars => $1 ] ];
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
  return prs_call('',  @tok);
}

sub prs_call ($end, @tok) {
  my @reslist = (my $res = []);
  my $end_ok = 0+!$end;
  while (my $m = shift @tok) {
    if ($end && $m->[0] eq $end) {
      $end_ok = 1;
      last;
    }
    if ($m->[0] eq 'SemiColon') {
      push(@reslist, $res = []);
      next;
    }
    my $ret;
    if ($m->[0] eq 'EnterCall') {
      ($ret, @tok) = prs_call(LeaveCall => @tok)
    } else {
      $ret = $m;
    }
    push @$res, $ret;
  }
  die unless $end_ok;
  my @call = map +(@$_ ? _call(@$_) : ()), @reslist;
  return ($call[0], @tok); # LIES
}

sub read_string ($string) {
  prs tok $string;
}

1;
