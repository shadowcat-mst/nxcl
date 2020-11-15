package XCL0::00::Reader;

use XCL0::Exporter;

our @EXPORT_OK = qw(read_string);

sub _tok ($str) {
  return () unless length $str;
  my $tok;
  local $_ = $str;
  s/^\s+//;
  $tok = do {
    if (/^[A-Za-z_]/) {
      s/^([A-Za-z_0-9\-?]+)// or die;
      [ Name00 => [ chars => $1 ] ];
    } elsif (/^'/) {
      s{'((?:[^'\\\\]+|\\\\.)*)'}{} or die;
      [ String00 => [ chars => $1 ] ];
    } elsif (s/^\[//) {
      [ EnterCall00 => [ 'nil' ] ];
    } elsif (s/^\]//) {
      [ LeaveCall00 => [ 'nil' ] ];
    } elsif (s/^;//) {
      [ SemiColon00 => [ 'nil' ] ];
    } else {
      die $_;
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
  [ List00 => [ cons =>
    $first,
    (@rest ? _list(@rest) : [ List00 => [ 'nil' ] ])
  ] ]
}

sub _call (@args) {
  [ Call00 => _list(@args)->[1] ]
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
    if ($m->[0] eq 'SemiColon00') {
      push(@reslist, $res = []);
      next;
    }
    my $ret;
    if ($m->[0] eq 'EnterCall00') {
      ($ret, @tok) = prs_call(LeaveCall00 => @tok)
    } else {
      $ret = $m;
    }
    push @$res, $ret;
  }
  die unless $end_ok;
  my @call = map +(@$_ ? _call(@$_) : ()), @reslist;
  die unless @call; # ?
  return ($call[0], @tok) if @call == 1;
  return (_call([ Name00 => [ chars => '_progn' ] ], @call), @tok);
}

sub read_string ($string) {
  prs tok $string;
}

1;
