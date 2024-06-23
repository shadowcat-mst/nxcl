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

  expr ([ first, ...rest ]) {
    let message = proto.core[rest.length ? 'CALL' : 'EVAL'];
    return this.send(first, message, rest);
  }

  *send (val, message, args) {
    let method = yield* this.scope.getMethod(this, val, message);
    if (!method) {
      // message may be a Symbol
      throw `No such method ${message.toString()} on ${val}`;
    }
    return yield* method.call(val, this, args);
  }
}
