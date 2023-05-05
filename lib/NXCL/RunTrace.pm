package NXCL::RunTrace;

use NXCL::Package;
use NXCL::YDump;
use NXCL::Writer;
use NXCL::OpUtils;

our $Count = 0;
our $Show_OpQ = 0;
our $Max;

sub import {
  $Max = $_[1] if defined $_[1];
  require NXCL::Environment;
  $NXCL::Environment::DEFAULT_TRACE_CB = \&DEBUG_WARN;
}

use NXCL::ScopeT;
use Hash::Util qw(fieldhash);
fieldhash my %scopes;
BEGIN {
  my $idx = 'A000';
  for ($NXCL::TypeRegistry::TypeInfo{Scope}->exports->{make_Scope}) {
    $_ = do { my $v = $_; sub { my $s = &$v; $scopes{$s} = ++$idx; $s } }
  }
  my $v = NXCL::ScopeT->can('make');
  my $wrapped = sub { my $s = &$v; $scopes{$s} = ++$idx; $s };
  no warnings 'redefine';
  *NXCL::ScopeT::make = $wrapped;
}
fieldhash my %op_origins;
BEGIN {
  my $make_op = NXCL::OpUtils->can('make_op');
  my $wrapped = sub {
    my %origin;
    my $level = 2;
    while (1) {
      my ($package)
        = (undef, @origin{qw(filename line sub)})
        = caller($level);
      last unless
        $package eq 'NXCL::TypeMethod'
        or $package eq 'NXCL::MethodUtils';
      ++$level;
    }
    while (1) {
      my $callsub = $origin{callsub} = (caller($level+1))[3];
      last unless $callsub eq 'NXCL::Runtime::take_method_step';
      ++$level;
    }
    if (my $inc_file = { reverse %INC }->{$origin{filename}}) {
      $origin{filename} = $inc_file;
    }
    s/^NXCL::/+/ for @origin{qw(sub callsub)};
    my $op = $make_op->(@_);
    $op_origins{$op} = \%origin;
    return $op;
  };
  no warnings 'redefine';
  *NXCL::OpUtils::make_op = $wrapped;
}
use NXCL::Utils qw(uncons object_is raw flatten);
use NXCL::TypeFunctions qw(
  Scope_Inst make_String make_Compound make_Name make_Int name_of_Native
);
use NXCL::JSON;

sub jsonify ($v) {
  return undef unless defined $v;
  if (object_is $v, Scope_Inst) {
    return [ "Scope (dict) SCOPE_".$scopes{$v} ];
  }
  # Not an infite loop, we still call the nxcl2json we imported earlier
  no warnings 'redefine';
  local *NXCL::JSON::nxcl2json = \&jsonify;
  return NXCL::JSON::_nxcl2json($v);
}

sub _wrap_perl_value ($v) {
  make_Compound(
    make_Name('<'),
    (defined($v)
      ? ($v =~ /^\d+$/ ? make_Int($v) : make_String($v))
      : make_Name('undef')),
    make_Name('>'),
  );
}

sub DEBUG_WARN ($cxs, $ops) {
  if (my $origin = $op_origins{$ops->[-1]}) {
    warn join(' ', '#', @{$origin}{qw(callsub sub filename line)})."\n";
  }
  eval {
#    my ($pst, @stst) = map {
#      my ($op, @v) = @$_;
#      [ $op => map jsonify(ref() ? $_ : make_String($_//'NULL')), @v ];
#    } ($Show_OpQ ? reverse @$ops : $ops->[-1]);
#    warn join('',
#      ydump($pst) =~ s/^/  /mgr,
#      map ydump($_) =~ s/^/+ /mgr, @stst
#    )."\n";

    state $w = NXCL::Writer->new;

    local *NXCL::Writer::_write_type_Native = sub ($self, $v) {
      '<'.name_of_Native($v).'>'
    };

    local *NXCL::Writer::_write_type_Scope = sub ($self, $v) {
      'S_'.$scopes{$v}
    };

    my ($op, @v) = @{$ops->[-1]};

    my @wv = map $w->write(ref() ? $_ : _wrap_perl_value $_), @v;
    warn join(' ', $op, @wv)."\n";

    1;
  } or do {
    warn "aborting from DEBUG_WARN: $@\n";
    exit 255;
  };
  if (defined $Max) {
    $Count++;
    exit if $Count >= $Max;
  }
}

1;
