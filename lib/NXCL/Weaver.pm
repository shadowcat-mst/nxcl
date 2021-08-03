package NXCL::Weaver;

use NXCL::Utils qw(mset object_is flatten raw);
use NXCL::TypeRegistry qw(mset_name);
use NXCL::TypeMaker;
use NXCL::TypeFunctions qw(
  make_List
  make_Call
  make_BlockProto
  make_Combine
  cons_Combine
  make_Compound
  Name_Inst
  Combine_Inst
  Compound_Inst
);
use NXCL::BaseOps qw(@WEAVE_OPS);
use List::UtilsBy qw(max_by);
use NXCL::Class;

lazy binops => sub ($self) { $self->expand_binop_list(@WEAVE_OPS) };

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

sub weave ($self, $v) {
  my $mset_name = mset_name mset $v;
  if (my $weaver = $self->can("_weave_type_${mset_name}")) {
    return $self->$weaver($v);
  }
  return $v;
}

sub _weave_type_Numeric ($self, $v) {
  my $raw = raw($v);
  make_value($raw =~ /\./ ? 'Float' : 'Int', $raw);
}

sub _weave_type_List ($self, $v) { $self->_flat_weave(\&make_List, $v) }
sub _weave_type_Call ($self, $v) { $self->_flat_weave(\&make_Call, raw($v)) }
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
  return $self->_flat_weave($make, $v) unless @parts > 2;
  my %binops = %{$self->binops};
  my @op_cand = map {
    my $p = $parts[$_];
    if (object_is($p, Name_Inst) and my $op = $binops{raw($p)}) {
      [ $_ => @$op ]
    } else {
      ()
    }
  } 1..$#parts-1;
  return $self->_flat_weave($make, $v) unless @op_cand; # no ops, skip
  my $op_spec = max_by { $_->[2] } @op_cand;
  my ($op_idx, $op_type) = @$op_spec;
  my @pre = map $self->weave($_), @parts[0..$op_idx-1];
  my $op = $parts[$op_idx];
  my @post = map $self->weave($_), @parts[$op_idx+1..$#parts];
  return $self->${\"_weave_op_${op_type}"}($make, $op, \@pre, \@post);
}

sub _weave_op_basic ($self, $make, $op, $pre, $post) {
  make_Combine(
    $op,
    @$pre, @$post
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
      cons_Combine(
        make_Combine($op, pop(@pre), shift(@post)),
        shift(@post)
      );
    } elsif ($make == \&make_Combine and object_is($post[0], Compound_Inst)) {
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
  return $dot unless @pre or @post;
  return $self->weave($make->(@pre, $dot, @post));
}

1;
