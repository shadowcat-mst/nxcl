import { proto } from "../constants.js";
import { Value, Val, List } from "../valuetypes.js";
import { withAssigner } from "../kw/let.js";

let tokenSlot = Symbol('xcl.value.fexpr.tokenSlot');

class ReturnTarget {
  [tokenSlot] = Symbol('xcl.value.fexpr.ReturnTarget.token');

  withValue (value) {
    let copy = {
      __proto__: this.constructor.prototype,
      [tokenSlot]: this[tokenSlot],
      value
    };
    return copy;
  }
}

class ReturnTo extends Value {

  *[proto.core.CALL] (cx, args) {
    let value = yield* cx.eval(args[0]);
    throw this.returnTarget.withValue(value);
  }
}

export class Fexpr extends Value {

  *[proto.core.CALL] (callcx, args) {
    let scope = yield* this.scope.derive();
    yield* scope.setCell(callcx, 'callcx', new Val({ value: callcx }));

    let returnTarget = new ReturnTarget();
    let returnToken = returnTarget[tokenSlot];
    let returnTo = new ReturnTo({ returnTarget });
    yield* scope.setCell(callcx, 'return', new Val({ value: returnTo }));

    let cx = yield* callcx.derive({ scope });

    let acx = yield* withAssigner(cx, Val);
    let arglist = new List({ contents: args });
    yield* acx.send(this.argspec, proto.core.ASSIGN_VALUE, [ arglist ]);

    try {
      return yield* cx.send(this.body, proto.core.CALL, []);
    } catch (e) {
      if (e instanceof ReturnTarget && e[tokenSlot] === returnToken) {
        return e.value;
      }
      throw(e); // Not ours, pass it upwards
    }
  }
}
