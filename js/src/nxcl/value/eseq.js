import { proto } from "../constants.js";
import { Value } from "../value.js";

let { EVAL, CALL } = proto.core;

export class ESeq extends Value {

  [EVAL] (cx) {
    return this[CALL](cx, []);
  }

  *[CALL] (cx, args) {
    let contents = [ ...this.contents ];
    let last = contents.pop();
    for (let expr of contents) { yield* cx.eval(expr) }
    return yield* cx.eval(last);
  }
}
