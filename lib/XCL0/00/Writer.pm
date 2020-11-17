package XCL0::00::Writer;

use XCL0::Exporter;
use XCL0::00::Runtime qw(type rtype raw flatten car cdr refp deref);
use Sub::Util qw(subname);

our @EXPORT_OK = qw(write_string);

sub write_string ($v) {
  return '??NULL??' unless defined($v);
  my $type = type $v;
  return raw($v) if $type eq 'Name00';
  return q{'}.raw($v).q{'} if $type eq 'String00'; # yes, I know.
  if ($type eq 'Bool00')  {
    return raw($v) ? 'true' : 'false';
  }
  if ($type eq 'Call00') {
    return join ' ', '[', (map write_string($_), flatten($v)), ']';
  }
  if ($type eq 'List00') {
    return '('.join(', ', map write_string($_), flatten($v)).')';
  }
  if ($type eq 'Fexpr00') {
    if (rtype($v) eq 'native') {
      my $name = subname(raw $v);
      if (my ($bif) = $name =~ /^XCL0::00::\w+::(.*)$/) {
        return 'Bif00('.$bif.')';
      }
      return 'Fexpr00(native '.$name.')';
    }
    return 'Fexpr00('.write_string(cdr $v).')';
  }
  if (refp $v) {
    return $type.'('.write_string(deref $v).')';
  }
  return $type.'()';
}

1;
