import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Message extends Value {

  *[proto.core.CALL] (cx, args) {
    if (!Object.hasOwn(this, 'args')) {
      let args = yield* cx.eval(args);
      return new this.constructor({ ...this, args });
    }
    let [ target, ...sendArgs ] = [
      ...(this.target ? [this.target] : []), ...this.args, ...args
    ];
    return yield* cx.send(target, this.messageId, sendArgs);
  }
}
