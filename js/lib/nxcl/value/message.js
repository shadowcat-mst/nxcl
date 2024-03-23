import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Message extends Value {

  *[proto.core.CALL] (cx, args) {
    if (!Object.hasOwn(this, 'args')) {
      let args = yield* cx.eval(args);
      return new this.constructor({ ...this, args });
    }
    let target, sendArgs;
    if (target = this.target) {
      sendArgs = [ ...this,args, ...args ];
    } else {
      let [ first, ...rest ] = args;
      target = yield* cx.eval(first);
      sendArgs = [ ...this.args, ...rest ];
    }
    return yield* cx.send(target, this.message, sendArgs);
  }
}
