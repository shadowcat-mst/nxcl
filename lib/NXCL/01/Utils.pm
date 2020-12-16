package NXCL::01::Utils;

use NXCL::Exporter;
use Sub::Util qw(set_subname);
use NXCL::00::Runtime qw();

our @EXPORT_OK = qw(
  panic
  not_combinable
  evaluate_to_value
  make_const_combiner
  make_string_combiner
  Make
  nil cons list1
);

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

sub make_const_combiner ($constant) {
  my ($hex) = $constant =~ m/\(0x(\w+)\)/;
  return set_subname 'const_'.$hex =>
    sub ($scope, $args, $combiner, $kstack) {
      return evaluate_to_value($scope, $constant, $kstack);
    };
}

sub make_string_combiner ($string) {
  return set_subname 'const_string_'.$string =>
    make_constant_combiner(String($string));
}

sub Make ($name, @make) {
  mkv($NXCL::01::Types::Types{$name}, @make);
}

sub nil { Make List => 'nil' }

sub Cons { Make List => cons => @_ }

sub List1 ($v) { Make List => cons => $v => nil() }

sub LazyCons { Make LazyList => cons => @_ }

sub FlatCons { Make FlatList => cons => @_ }


1;
