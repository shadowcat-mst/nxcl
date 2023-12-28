"use strict";

const qw = s => s.split(' ');

const make = (src) => Object.freeze(
  Object.assign(
    Object.create(null),
    (src instanceof Array ? Object.from_entries(src) : src),
  )
);

const symSet = (name, values) => [
  name, make(values.map(v => [ v, Symbol([ name, v ].join('.')) ]),
];

export const proto = make([
  symSet('core', qw`EVAL CALL ASSIGN_VALUE ASSIGN_VIA_CALL`),
]);
