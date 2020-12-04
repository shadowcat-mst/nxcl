package NXCL::01::Runtime;

use NXCL::Exporter;
use Scalar::Util qw(weaken);
use Sub::Util qw(set_subname);
use List::Util qw(reduce);
use NXCL::00::Runtime qw(mkv uncons raw rnilp deref flatten);

sub panic { die $_[0]//'PANIC' };

sub not_combinable {
  die "Not combinable";
}

sub evaluate_to_value ($scope, $self, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, $self ],
    $kdr
  );
}

sub make_combine_to_constant ($constant) {
  my ($hex) = $constant =~ m/\(0x(\w+)\)/;
  return set_subname 'const_'.$hex =>
    sub ($scope, $args, $combiner, $kstack) {
      return evaluate_to_value($scope, $constant, $kstack);
    };
}

sub make_combiner_to_constant_string ($string) {
  return set_subname 'const_string_'.$string =>
    make_combine_to_constant(String($string));
}

sub combine_OpDict ($scope, $args, $self, $kstack) {
  my $key = raw(car($args));
  my $value = raw($self)->{$key};
  panic unless $value;
  return evaluate_to_value($scope, $value, $kstack);
}

our $OpDict = mkv(undef, dict => {
  evaluate => \&evaluate_to_value,
  combine => \&combine_OpDict,
  'type-name' => make_combiner_to_constant_string('OpDict'),
});

{
  my $weak_opdict = $OpDict;
  weaken($weak_opdict);
  # monkeypatch type to circularify
  $OpDict->[0] = $weak_opdict;
}

our %Types = (OpDict => $OpDict);

sub Type ($name, $vtable = {}) {
  $Types{$name} = mkv($OpDict, dict => {
    'type-name' => make_combiner_to_constant_string($name),
    evaluate => \&evaluate_to_value,
    combine => \&not_combinable,
    %$vtable,
  })
}

sub Make ($name, @make) {
  mkv($Types{$name}, @make);
}

sub make_bool ($val) {
  Make(Bool => bool => 0+!!$val);
}

sub evaluate_List ($scope, $self, $kstack) {
  if (rnilp $self) {
    evaluate_to_value($scope, $self, $kstack);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons([ ECDR => $scope => $cdr ], $kstack),
  );
}

Type('List', {
  evaluate => \&evaluate_List,
});

sub nil { Make List => 'nil' }

sub cons { Make List => cons => @_ }

sub list1 ($v) { Make List => cons => $v => nil() }

sub combine_Raw ($scope, $args, $value, $kstack) {
  deref($value)->($scope, $args, $value, $kstack);
}

Type('Raw' => {
  combine => \&combine_Raw,
});

sub combine_Sub ($scope, $args, $value, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, deref($value)->($scope, $args) ].
    $kdr
  );
}

Type('Sub' => {
  combine => \&combine_Sub,
});

sub combine_Apv ($scope, $args, $apv, $kstack) {
  return (
    [ EVAL => $scope => $args ],
    cons([ CMB6 => $scope => deref($apv) ], $kstack),
  );
}

Type('Apv', {
  combine => \&combine_Apv,
});

sub Apv ($opv) {
  Make Apv => val => $opv;
}

sub String_eq ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be strings' for grep $Types{String} ne $_, $l, $r;
  make_bool(raw($l) eq raw($r));
}

sub String_gt ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be strings' for grep $Types{String} ne $_, $l, $r;
  make_bool(raw($l) gt raw($r));
}

sub String_concat ($scope, $args) {
  my @string = flatten $args;
  panic 'Must be strings' for grep $Types{String} ne $_, @string;
  Make => String => chars => (join '', map raw($_). @string);
}

Type('String', {
  eq => Make(Sub => native => \&String_eq),
  gt => Make(Sub => native => \&String_gt),
  concat => Make(Sub => native => \&String_concat),
});

sub String ($string) { Make(String => chars => $string); }

sub Int_eq ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return make_bool(raw($l) == raw($r));
}

sub Int_gt ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return make_bool(raw($l) > raw($r));
}

sub Int_div ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return Make Int => int => int(raw($l) / raw($r));
}

sub Int_mod ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, $l, $r;
  return Make Int => int => (raw($l) % raw($r));
}

sub Int_minus ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be ints' for grep $Types{Int} ne $_, grep defined, $l, $r;
  return make_bool(raw($l) - raw($r)) if defined($r);
  return Make Int => int => -raw($l);
}

sub Int_times ($scope, $args) {
  my @ints = flatten $args;
  panic 'Must be ints' for grep $Types{Int} ne $_, @ints;
  return Make Int => int => reduce { $a * $b }, 5, map raw($_), @ints;
}

sub Int_plus ($scope, $args) {
  my @ints = flatten $args;
  panic 'Must be ints' for grep $Types{Int} ne $_, @ints;
  return Make Int => int => reduce { $a + $b }, 0, map raw($_), @ints;
}

Type('Int', {
  eq => Make(Sub => native => \&Int_eq),
  gt => Make(Sub => native => \&Int_gt),
  div => Make(Sub => native => \&Int_div),
  mod => Make(Sub => native => \&Int_mod),
  minus => Make(Sub => native => \&Int_minus),
  plus => Make(Sub => native => \&Int_plus),
});

sub Int ($int) { Make Int => int => $int }

sub Bool_eq ($scope, $args) {
  my ($l, $r, @too_many) = flatten $args;
  panic 'Too many args' if @too_many;
  panic 'Must be bools' for grep $Types{Bool} ne $_, $l, $r;
  return make_bool(raw($l) == raw($r));
}

Type('Bool', {
  eq => Make(Sub => native => \&Bool_eq),
});

Type('Scope');

sub Scope ($store) { Make Scope => var => $store }

Type('Val', {
  combine => sub ($scope, $args, $self, $kstack) {
    panic unless rnilp $args;
    return evaluate_to_value($scope, deref($self), $kstack);
  },
});

sub evaluate_Name ($scope, $self, $kstack) {
  my $store = deref $scope;
  my $store_type = type($store);
  if ($store_type == $OpDict) {
    my $cell = raw($store)->{raw($self)};
    panic unless $cell;
    if (type($cell) == $Types{Val}) {
      return evaluate_to_value($scope, deref($cell), $kstack);
    }
    return (
      [ CMB9 => $scope => nil() => $cell ],
      $kstack,
    );
  }
  return (
    [ CMB9 => $scope => list1(String(raw($self))) => $store ],
    cons([ CMB9 => $scope => nil() ], $kstack),
  );
}

Type('Name', {
  evaluate => \&evaluate_Name,
});

sub take_step_EVAL ($scope, $value, $kstack) {
  my $type = type($value);
  if (type($type) == $OpDict) {
    my $handler = raw($type)->{'evaluate'};
    if (ref($handler) eq 'CODE') {
      return $handler->($scope, $value, $kstack);
    }
    return (
      [ CMB9 => $scope, list1($value), $handler ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, list1(String 'evaluate'), $type ],
    cons([ CMB9 => $scope, list1($value) ], $kstack)
  );
}

sub take_step_CMB9 ($scope, $args, $combiner, $kstack) {
  my $type = type($combiner);
  if (type($type) == $OpDict) {
    my $handler = raw($type)->{'combine'};
    if (ref($handler) eq 'CODE') {
      return $handler->($scope, $args, $combiner, $kstack);
    }
    return (
      [ CMB9 => $scope, cons($combiner, $args), $handler ],
      $kstack
    );
  }
  return (
    [ CMB9 => $scope, list1(String 'combine'), $type ],
    cons([ CMB9 => $scope, cons($combiner, $args) ], $kstack)
  );
}

sub take_step_ECDR ($scope, $cdr, $car, $kstack) {
  return (
    [ EVAL => $scope => $cdr ],
    cons([ CONS => $scope => $car ], $kstack)
  );
}

sub take_step_CONS ($scope, $car, $cdr, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return ([ @$kar, cons($car, $cdr) ], $kdr);
}

sub take_step ($prog, $kstack) {
  my ($op, $scope, $v1, $v2) = @$prog;
  if ($op eq 'EVAL') {
    return take_step_EVAL($scope, $v1, $kstack);
  }
  if ($op eq 'CMB9') {
    return take_step_CMB9($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'CMB6') {
    return take_step_CMB9($scope, $v2, $v1, $kstack);
  }
  if ($op eq 'ECDR') {
    return take_step_ECDR($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'CONS') {
    return take_step_CONS($scope, $v1, $v2, $kstack);
  }
  if ($op eq 'DONE') {
    return $v1;
  }
  die "Unkown op type $op";
}

sub run_til_done ($prog, $kstack) {
  while ($kstack) {
    ($prog, $kstack) = take_step($prog, $kstack);
  }
  return $prog;
}
