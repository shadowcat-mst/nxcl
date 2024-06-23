import { Scope } from "./scope.js";
import { proto, pub } from "./constants.js";
import { Val, Message, Bool } from "./valuetypes.js";

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

val('true', new Bool({ value: true }));
val('false', new Bool({ value: false }));

export function baseScope () {
  return new Scope({ cells, ops });
}
