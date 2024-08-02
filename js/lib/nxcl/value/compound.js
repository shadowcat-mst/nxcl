import { proto } from "../constants.js";
import { Value } from "../value.js";
import { List } from "./list.js";

let { EVAL } = proto.core;

export class Compound extends Value {

  *[EVAL] (cx) {
    let [ first, ...rest ] = this.contents;
    let cur = yield* cx.eval(first);
    for (let r of rest) {
      cur = yield* cx.call(cur, r instanceof List ? r.contents : [r]);
    }
    return cur;
  }

  toExternalString () {
    return this.contents.map(v => v.toExternalString()).join('')
  }
}
