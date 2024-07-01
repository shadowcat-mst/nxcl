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
      mapped.push(...ret instanceof List ? ret.contents: [ret]);
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
    if (!(other instanceof this.constructor)) {
      throw "List.concat but not a List";
    }
    let contents = this.contents.concat(other.contents);
    return new this.constructor({ contents });
  }

  [proto.core.CALL] (...args) { return this[proto.collection.at](...args) }

  *[proto.core.ASSIGN_VALUE] (cx, args) {
    let v = yield* cx.eval(args[0]);
    if (!(v instanceof this.constructor)) {
      throw "List.ASSIGN_VALUE but not a List";
    }
    if (this.contents.length != v.contents.length) {
      throw "List.ASSIGN_VALUE but different lengths";
    }
    let assignTo = this.contents, assignFrom = v.contents;
    for (let i in assignTo) {
      yield* cx.send(assignTo[i], proto.core.ASSIGN_VALUE, [ assignFrom[i] ]);
    }
    return v;
  }

  toExternalString () { return '(' + this.valueToExternalString() + ')' }
}
