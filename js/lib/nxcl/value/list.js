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
    let at = yield* Int.prototype._toInt(cx, atp);
    return this.contents[at.value];
  }

  *[proto.core.EVAL] (cx) {
    let contents = [];
    for (let vp of this.contents) {
      let v = yield* cx.eval(vp);
      contents.push(v);
    }
    return new this.constructor({ contents });
  }

  *[proto.core.concat] (cx, [ otherp ]) {
    let other = yield* cx.eval(otherp);
    if (!(other instanceof this.constructor)) throw "ARGH";
    let contents = this.contents.concat(other.contents);
    return new this.constructor({ contents });
  }

  [proto.core.CALL] (...args) { return this[proto.collection.at](...args) }

  toExternalString () { return '(' + this.valueToExternalString() + ')' }
}
