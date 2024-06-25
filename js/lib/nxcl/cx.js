import { proto } from "./constants.js";

export class Cx {

  constructor (opts) {
    Object.assign(this, opts);
  }

  eval (val) {
    return this.send(val, proto.core.EVAL, []);
  }

  call (val, args) {
    return this.send(val, proto.core.CALL, args);
  }

  *send (val, message, args) {
    yield [ val, message, args ];
    let method = yield* this.scope.getMethod(this, val, message);
    if (!method) {
      // message may be a Symbol
      throw `No such method ${message.toString()} on ${val}`;
    }
    return yield* method.call(val, this, args);
  }
}
