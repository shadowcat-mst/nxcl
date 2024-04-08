import { proto } from "../constants.js";
import { Value } from "../value.js";
import { List } from "./list.js";

export class Compound extends Value {

  *[proto.core.EVAL] (cx) {
    let [ first, ...rest ] = this.contents;
    let cur = yield* cx.eval(first);
    for (let r of rest) {
      cur = yield* cx.call(cur, r instanceof List ? r.contents : [r]);
    }
    return cur;
  }
}
