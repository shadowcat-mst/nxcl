import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Message extends Value {

  constructor ({ messageId, target, args }, metadata) {
    Object.assign(this, { messageId, target, args, metadata });
  }

  *[proto.core.CALL] (cx, args) {
    if (!Object.hasOwn(this, 'args')) {
      let args = yield* cx.eval(args);
      return new this.constructor({ ...this, args }, this.metadata);
    }
    let [ target, ...sendArgs ] = [
      ...(this.target ? [this.target] : []), ...this.args, ...args
    ];
    return yield* cx.send(target, this.messageId, sendArgs);
  }
}
