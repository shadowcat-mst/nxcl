import { proto, pub } from "../constants.js";
import { Value } from "../value.js";

export class Int extends Value {

  *_binOp (cx, otherp, cb) {
    let other = yield* cx.eval(otherp);
    if (!(other instanceof Int)) {
      other = yield* cx.send(other, proto.numeric.to_int);
    }
    let value = cb(this.value, other.value);
    return new this.constructor({ ...this, value });
  }

  [pub.plus] (...args) { return this[proto.numeric.plus](...args) }

  [proto.numeric.plus] (cx, [ otherp ]) {
    return this._binOp(cx, otherp, (x,y) => x+y);
  }

  [pub.minus] (...args) { return this[proto.numeric.minus](...args) }

  [proto.numeric.minus] (cx, [ otherp ]) {
    return this._binOp(cx, otherp, (x,y) => x-y);
  }

  [pub.to_int] (...args) { return this[proto.numeric.to_int](...args) }

  *[proto.numeric.to_int] () { return this }
}
