import { Scope } from "./scope.js";
import { proto, pub } from "./constants.js";
import { Value, Val, Message, Bool } from "./valuetypes.js";
import { letKeyword, varKeyword } from "./kw/let.js";
import { dotKeyword } from "./kw/dot.js";
import { fexprKeyword, funKeyword } from "./kw/fexpr.js";
import { equalsKeyword } from "./kw/equals.js";
import { quoteKeyword, identityKeyword } from "./kw/identity.js";
import { dynamicKeyword } from "./kw/dynamic.js";

let { core, numeric } = proto;

let cells = {}, ops = {};

function val (symbol, value) {
  cells[symbol] = new Val({ value });
}

function binOp (precedence, symbol, valuep, opts) {
  let value;
  if (typeof valuep == 'symbol') {
    value = new Message({ call: valuep, args: [] });
  } else {
    value = valuep;
  }
  val(symbol, value);
  ops[symbol] = { precedence, ...opts };
}

let tightRight = true;

binOp(0, '+', numeric.plus);
binOp(0, '-', numeric.minus);
binOp(0, '==', numeric.eq);
// binOp(0, '.', core.DOT, { tightRight });
binOp(0, '++', core.concat, 0);

binOp(0, '=', equalsKeyword);

val('true', new Bool({ value: true }));
val('false', new Bool({ value: false }));

binOp(0, '.', dotKeyword, { tightRight });
val('let', letKeyword);
val('var', varKeyword);
val('fexpr', fexprKeyword);
val('fun', funKeyword);
val('\\', quoteKeyword);
val('$', identityKeyword);
val('dynamic', dynamicKeyword);

export function baseScope () {
  return new Scope({ cells, ops });
}
