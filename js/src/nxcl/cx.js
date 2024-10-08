import { proto, pub } from "./constants.js";
import { Value } from "./value.js";

let { EVAL, CALL } = proto.core;

let valueEval = Value.prototype[EVAL];

export class Cx extends Value {

  dynamics = this.dynamics ?? { __proto__ : null };

  *[pub.eval] (cx, [ valuep ]) {
    let value = yield* cx.eval(valuep);
    return yield* this.eval(value);
  }

  *eval (val) {
    if (val[EVAL] === valueEval) {
      return val;
    }
    return yield* this.send(val, EVAL, []);
  }

  *call (val, args) {
    return yield* this.send(val, CALL, args);
  }

  *send (val, message, args) {
    yield [ '+', val, message, args ];
    let method = yield* this.scope.getMethod(this, val, message);
    if (!method) {
      // message may be a Symbol
      throw `No such method ${message.toString()} on ${val}`;
    }
    let ret = yield* method.call(val, this, args);
    yield [ '-', ret ];
    return ret;
  }

  *derive ({ scope, dynamics } = {}) {
    scope ??= yield* this.scope.derive();
    dynamics ??= { __proto__: this.dynamics };
    return new this.constructor({ scope, dynamics });
  }
}
