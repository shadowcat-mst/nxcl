import { proto, pub } from "./constants.js";
import { Value } from "./value.js";

export class Cx extends Value {

  // these are equivalent to e.g.
  // eval* (val) { return yield* this.send(...) }

  *[pub.eval] (cx, [ valuep ]) {
    let value = yield* cx.eval(valuep);
    return yield* this.eval(value);
  }

  eval (val) {
    return this.send(val, proto.core.EVAL, []);
  }

  call (val, args) {
    return this.send(val, proto.core.CALL, args);
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

  *derive ({ scope } = {}) {
    scope ??= yield* this.scope.derive();
    return new this.constructor({ scope });
  }
}
