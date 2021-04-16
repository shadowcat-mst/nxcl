package NXCL::01::Weaver;

use NXCL::01::Utils qw(mset flatten raw);
use NXCL::01::TypeRegistry qw(mset_name);
use NXCL::01::TypeFunctions qw(
  make_List
  make_Call
  make_BlockProto
  make_Combine
  make_Compound
  Name_Inst
  Combine_Inst
  Compound_Inst
);
use List::UtilsBy qw(max_by);
use NXCL::Class;

our @BASIC_BINOPS = do {
  my $basic = '
    + -
    * /
    < > <= >=
    == !=
    ++
    //
    &&
    ||
    ..
    |
    =
    and
    or
  ';
  map [ map [ basic => $_ ], /(\S+)/g ], grep /\S/, split "\n", $basic
};

our @DEFAULT_BINOPS = (
  [ [ dot => '.' ] ],
  [ [ tight => '=>' ] ],
  @BASIC_BINOPS,
  [ [ flip => 'if' ], [ flip => 'unless' ] ],
);

sub expand_binop_list ($self, @op_list) {
  my %binops;
  foreach my $idx (0..$#op_list) {
    foreach my $op_meta (@{$op_list[$idx]}) {
      my ($type, $op) = @$op_meta;
      $binops{$op} = [ $type, $idx ];
    }
  }
  return \%binops;
}

lazy binops => sub ($self) { $self->expand_binop_list(@DEFAULT_BINOPS) };

sub weave ($self, $v) {
  my $mset_name = mset_name mset $v;
  if (my $weaver = $self->can("_weave_type_${mset_name}")) {
    return $self->$weaver($v);
  }
  return $v;
}

sub _weave_type_List ($self, $v) { $self->_flat_weave(\&make_List, $v) }
sub _weave_type_Call ($self, $v) { $self->_flat_weave(\&make_Call, $v) }
sub _weave_type_BlockProto ($self, $v) {
   $self->_flat_weave(\&make_BlockProto, $v)
}

sub _flat_weave ($self, $make, $v) {
  return $make->(map $self->weave($_), flatten $v);
}

sub _weave_type_Combine ($self, $v) { $self->_op_weave(\&make_Combine, $v) }
sub _weave_type_Compound ($self, $v) { $self->_op_weave(\&make_Compound, $v) }

sub _op_weave ($self, $make, $v) {
  my @parts = flatten $v;
  return $v unless @parts > 2;
  my %binops = %{$self->binops};
  my @op_cand = map {
    my $p = $parts[$_];
    if (mset($p) == Name_Inst and my $op = $binops{raw($p)}) {
      [ $_ => @$op ]
    } else {
      ()
    }
  } 1..$#parts-1;
  return $v unless @op_cand; # no ops, skip
  my $op_spec = max_by { $_->[2] } @op_cand;
  my ($op_idx, $op_type) = @$op_spec;
  my @pre = @parts[0..$op_idx-1];
  my $op = $parts[$op_idx];
  my @post = @parts[$op_idx+1..$#parts];
  return $self->${\"_weave_op_${op_type}"}($make, $op, \@pre, \@post);
}

sub _weave_op_basic ($self, $make, $op, $pre, $post) {
  make_Combine(
    $op,
    map { @$_ > 1 ? $self->weave($make->(@$_)) : $_ } $pre, $post
  );
}

sub _weave_op_flip ($self, $make, $op, $pre, $post) {
  $self->_weave_op_basic($self, $make, $op, $post, $pre);
}

sub _weave_op_tight ($self, $make, $op, $pre, $post) {
  my @pre = @$pre;
  my @post = @$post;
  my $tight = make_Combine($op, pop(@pre), shift(@post));
  return $self->weave($make->(@pre, $tight, @post));
}

sub _weave_op_dot ($self, $make, $op, $pre, $post) {
  my @pre = @$pre;
  my @post = @$post;
  my $dot = do {
    if ($make == \&make_Compound and @post > 1) {
      make_Combine(
        make_Combine($op, pop(@pre), shift(@post)),
        shift(@post)
      );
    } elsif ($make == \&make_Combine and mset($post[0]) == Compound_Inst) {
      my ($name, $args, @rest) = flatten shift(@post);
      unshift(@post, make_Compound(@rest));
      make_Combine(
        make_Combine($op, pop(@pre), $name),
        $args
      );
    } else {
      make_Combine($op, pop(@pre), shift(@post));
    }
  };
  return $self->weave($make->(@pre, $op, @post));
}

1;