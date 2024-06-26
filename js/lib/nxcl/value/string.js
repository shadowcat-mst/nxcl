import { proto, pub } from "../constants.js";
import { Value } from "../value.js";

export class String extends Value {
  [pub.concat] (...args) { return this[proto.core.concat](...args) }

  // this doesn't escape but getting the contents of the '...' to here from
  // the reader doesn't unescape either; this is basically temporary NYI
  toExternalString () { return "'" + this.value + "'" }

  *[proto.core.concat] (cx, [ otherp ]) {
    let other = yield* cx.eval(otherp);
    if (!(other instanceof this.constructor)) {
      throw "String.concat but not a String";
    }
    let value = this.value + other.value;
    return new this.constructor({ value });
  }
}
