import { Scope } from "./scope.js";
import { proto, pub } from "./constants.js";
import { Value, Val, Message, Bool } from "./valuetypes.js";
import { letKeyword, varKeyword } from "./kw/let.js";
import { dotKeyword } from "./kw/dot.js";
import { fexprKeyword } from "./kw/fexpr.js";

let cells = {}, ops = {};

function val (symbol, value) {
  cells[symbol] = new Val({ value });
}

function binOp (precedence, symbol, valuep, opts) {
  let value;
  if (typeof valuep == 'symbol') {
    value = new Message({ call: valuep, withArgs: [] });
  } else {
    value = valuep;
  }
  val(symbol, value);
  ops[symbol] = { precedence, ...opts };
}

let tightRight = true;

binOp(0, '+', proto.numeric.plus);
binOp(0, '-', proto.numeric.minus);
binOp(0, '==', proto.numeric.eq);
// binOp(0, '.', proto.core.DOT, { tightRight });
binOp(0, '++', proto.core.concat, 0);

binOp(0, '=', {
  __proto__: Value.prototype,
  *[proto.core.CALL] (cx, [ left, rightp ]) {
    let right = yield* cx.eval(rightp);
    return yield* cx.send(left, proto.core.ASSIGN_VALUE, [ right ]);
  },
  toExternalString () { return 'Native(=)' },
});

val('true', new Bool({ value: true }));
val('false', new Bool({ value: false }));

binOp(0, '.', dotKeyword, { tightRight });
val('let', letKeyword);
val('var', varKeyword);
val('fexpr', fexprKeyword);

export function baseScope () {
  return new Scope({ cells, ops });
}
