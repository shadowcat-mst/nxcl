import { Scope } from "./scope.js";
import { proto, pub } from "./constants.js";
import { Value, Val, Message, Bool } from "./valuetypes.js";
import { letKeyword } from "./kw/let.js";

let cells = {}, ops = {};

function binOp (symbol, call, precedence, opts) {
  cells[symbol] = new Val({ value: new Message({ call, withArgs: [] }) });
  ops[symbol] = { precedence, ...opts };
}

function val (symbol, value) {
  cells[symbol] = new Val({ value });
}

let tightRight = true;

binOp('+', proto.numeric.plus, 0);
binOp('-', proto.numeric.minus, 0);
binOp('==', proto.numeric.eq, 0);
binOp('.', proto.core.DOT, 0, { tightRight });

val('=', {
  __proto__: Value.prototype,
  *[proto.core.CALL] (cx, [ left, right ]) {
    return yield* cx.send(left, proto.core.ASSIGN_VALUE, [ right ]);
  },
  toExternalString () { return 'Native(=)' },
});
ops['='] = { precedence: 0 };

val('true', new Bool({ value: true }));
val('false', new Bool({ value: false }));

val('let', letKeyword);

export function baseScope () {
  return new Scope({ cells, ops });
}
