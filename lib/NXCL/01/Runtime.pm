package NXCL::01::Runtime;

use NXCL::Exporter;
use Scalar::Util qw(weaken);
use Sub::Util qw(set_subname);
use NXCL::00::Runtime qw(mkv uncons raw rnilp);

sub panic { die };

sub not_combinable {
  die "Not combinable";
}

sub evaluate_to_self ($scope, $self, $kstack) {
  my ($kar, $kdr) = uncons $kstack;
  return (
    [ @$kar, $self ],
    $kdr
  );
}

sub combine_to_constant ($constant) {
  my ($hex) = $constant =~ m/\(0x(\w+)\)/;
  return set_subname 'combine_to_constant_'.$hex =>
    sub ($scope, $args, $combiner, $kstack) {
      return evaluate_to_self($scope, $constant, $kstack);
    };
}

sub combine_to_constant_string ($string) {
  return set_subname 'combine_to_constant_string_'.$string =>
    combine_to_constant(String($string));
}

sub combine_OpDict ($scope, $args, $self, $kstack) {
  my $key = raw(car($args));
  my $value = raw($self)->{$key};
  panic unless $value;
  return evaluate_to_self($scope, $value, $kstack);
}

our $OpDict_T = mkv(undef, dict => {
  evaluate => \&evaluate_to_self,
  combine => \&combine_OpDict,
  'type-name' => combine_to_constant_string('OpDict'),
});

{
  my $weak_opdict_t = $OpDict_T;
  weaken($weak_opdict_t);
  # monkeypatch type to circularify
  $OpDict_T->[0] = $weak_opdict_t;
}

sub Type ($name, $vtable = {}) {
  mkv($OpDict_T, dict => {
    'type-name' => combine_to_constant_string($name),
    evaluate => \&evaluate_to_self,
    combine => \&not_combinable,
    %$vtable,
  })
}

sub evaluate_List ($scope, $self, $kstack) {
  if (rnilp $self) {
    evaluate_to_self($scope, $self, $kstack);
  }
  my ($car, $cdr) = uncons $self;
  return (
    [ EVAL => $scope => $car ],
    cons([ ECDR => $scope => $cdr ], $kstack),
  );
}

our $List_T = Type('List', {
  evaluate => \&evaluate_List,
});

sub nil { mkv $List_T => 'nil' }

sub cons { mkv $List_T => cons => @_ }

sub list1 ($v) { mkv $List_T => cons => $v => nil() }

our $String_T = Type('String');

sub String ($string) { mkv $String_T => chars => $string }

sub take_step_EVAL ($scope, $value, $kstack) {
  my $type = type($value);
  if (type($type) == $OpDict_T) {
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
  if (type($type) == $OpDict_T) {
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
