import { proto } from "../constants.js";
import { rewriteOps } from "../valuehelpers.js";
import { Value } from "../value.js";
import { List } from "./list.js";

export class Compound extends Value {

  *[proto.core.EVAL] (cx) {
    let rewritten = rewriteOps(cx, this);
    if (!rewritten instanceof Compound) {
      return yield* cx.eval(rewritten);
    }
    let [ first, ...rest ] = rewritten.data;
    let cur = yield* cx.eval(first);
    for (let r of rest) {
      cur = yield* cx.call(cur, r instanceof List ? r : new List(r));
    }
    return cur;
  }
}
