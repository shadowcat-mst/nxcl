import { proto, pub } from "../constants.js";
import { Value } from "../value.js";
import { Int } from "./int.js";

export class List extends Value {

  [pub.lmap] (...args) { return this[proto.collection.lmap](...args) }

  *[proto.collection.lmap] (cx, [ cbp ]) {
    let cb = yield* cx.eval(cbp);
    let mapped = [];
    for (let v of this.contents) {
      let ret = yield* cx.call(cb, [ v ]);
      if (!(ret instanceof List)) {
        ret = new List({ contents: [ret] });
      }
      mapped.push(...ret.contents);
    }
    return new this.constructor({ contents: mapped });
  }

  *[proto.collection.at] (cx, [ atp ]) {
    let at = yield* cx.eval(atp);
    if (!(at instanceof Int)) {
      at = yield* Int.prototype._toInt(cx, at);
    }
    return this.contents[at.value];
  }

  [proto.core.CALL] (...args) { return this[proto.collection.at](...args) }
}
