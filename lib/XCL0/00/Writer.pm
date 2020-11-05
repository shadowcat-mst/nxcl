package XCL0::00::Writer;

use XCL0::00::Runtime qw(type rtype raw flatten car cdr);
use Mojo::Base -strict, -signatures;
use Sub::Util qw(subname);
use Exporter 'import';

our @EXPORT_OK = qw(write_string);

sub write_string ($v) {
  my $type = type $v;
  return raw($v) if $type eq 'Name00';
  return q{'}.raw($v).q{'} if $type eq 'String00'; # yes, I know.
  if ($type eq 'Bool00')  {
    return raw($v) ? 'true' : 'false';
  }
  if ($type eq 'Call00') {
    return join ' ', '[', (map write_string($_), flatten($v)), ']';
  }
  if ($type eq 'List') {
    return '('.join(', ', map write_string($_), flatten($v)).')';
  }
  if ($type eq 'Native00') {
    return 'Native00('.(subname(raw $v) =~ s/^XCL0::00:://r).')';
  }
  if ($type eq 'Fexpr00') {
    return 'Fexpr00('.write_string(cdr $v).')';
  }
  return $type.'()';
}

1;
