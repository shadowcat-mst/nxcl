import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Call extends Value {

  *[proto.core.CALL] (cx, args) {
    let call = !args.length ? this : new this.constructor({
      ...this, contents: [ ...this.contents, ...args ],
    });
    return yield* cx.eval(call);
  }

  *[proto.core.EVAL] (cx) {
    let [ combinerp, ...args ] = this.contents;
    let combiner = yield* cx.eval(combinerp);
    return yield* cx.call(combiner, args);
  }
}
