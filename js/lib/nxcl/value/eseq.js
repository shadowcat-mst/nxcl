import { proto } from "../constants.js";
import { Value } from "../value.js";

export class ESeq extends Value {

  *[proto.core.CALL] (cx, args) {
    let contents = [ ...this.contents ];
    let last = contents.pop();
    for (let expr of contents) { yield* cx.eval(expr) }
    return yield* cx.eval(last);
  }
}
