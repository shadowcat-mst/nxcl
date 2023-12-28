import { proto } from "../constants.js";
import { Value } from "../value.js";
import { rewriteOps } from "../valuehelpers.js";

export class Call extends Value {

  *[proto.core.CALL] (cx, args) {
    let call = new this.constructor({
      ...this, data: [ ...this.data, ...args ],
    });
    return yield* cx.eval(call);
  }

  *[proto.core.EVAL] (cx) {
    let [ combinerp, ...args ] = rewriteOps(cx, this).data;
    let combiner = yield* cx.eval(combinerp);
    return yield* cx.call(combiner, args);
  }
}
