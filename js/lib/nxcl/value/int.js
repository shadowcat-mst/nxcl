import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Int extends Value {

  *[proto.numeric.plus] (cx, [ otherp ]) {
    let other = yield* cx.eval(otherp);
    if (!(other instanceof Int)) {
      other = yield* cx.send(other, proto.numeric.to_int);
    }
    let value = this.value + other.value;
    return new this.constructor({ ...this, value });
  }

  *[proto.numeric.to_int] () { return this }
}
