import { proto } from "../constants.js";
import { Value } from "../value.js";

export class String extends Value {
  // this doesn't escape but getting the contents of the '...' to here from
  // the reader doesn't unescape either; this is basically temporary NYI
  toExternalString () { return "'" + this.value + "'" }

  *[proto.core.concat] (cx, [ otherp ]) {
    let other = yield* cx.eval(otherp);
    if (!(other instanceof this.constructor)) throw "ARGH";
    let value = this.value + other.value;
    return new this.constructor({ value });
  }
}
