package NXCL::BaseOps;

use NXCL::Exporter;

our @EXPORT_OK = qw(@WEAVE_OPS %OP_MAP);

our @BASIC_BINOPS = do {
  my $basic = '
    * /
    + -
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

our @WEAVE_OPS = (
  [ [ dot => '.' ] ],
  [ [ tight => '=>' ] ],
  @BASIC_BINOPS,
  [ [ flip => 'if' ], [ flip => 'unless' ] ],
);

our %OP_MAP = do { my @ops = (
  plus => '+',
  minus => '-',
  times => '*',
  divide => '/',
  gt => '>',
  lt => '<',
  ge => '>=',
  lt => '<=',
  eq => '==',
  ne => '!=',
  concat => '++',
  exists_or => '//',
  and => '&&',
  or => '||',
  pipe => '|',
  assign => '=',
  and => 'and',
  or => 'or',
); reverse @ops };

1;
