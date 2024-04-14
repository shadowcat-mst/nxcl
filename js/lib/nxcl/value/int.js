import { proto, pub } from "../constants.js";
import { Value } from "../value.js";
import { Bool } from "./bool.js";

export class Int extends Value {

  constructor (opts) {
    if (! Number.isSafeInteger(opts.value)) throw "ARGH";
    super(opts);
  }

  *_toInt (cx, otherp) {
    let other = yield* cx.eval(otherp);
    if (other instanceof Int) return other;
    return yield* cx.send(other, proto.numeric.to_int);
  }

  *_binOp (cx, otherp, cb, constructor = this.constructor) {
    let other = yield* this._toInt(cx, otherp);
    let value = cb(this.value, other.value);
    return new constructor({ value });
  }

  [pub.plus] (...args) { return this[proto.numeric.plus](...args) }

  [proto.numeric.plus] (cx, [ otherp ]) {
    return this._binOp(cx, otherp, (x,y) => x+y);
  }

  [pub.minus] (...args) { return this[proto.numeric.minus](...args) }

  [proto.numeric.minus] (cx, [ otherp ]) {
    return this._binOp(cx, otherp, (x,y) => x-y);
  }

  [pub.eq] (...args) { return this[proto.numeric.eq](...args) }

  [proto.numeric.eq] (cx, [ otherp ]) {
    return this._binOp(cx, otherp, (x,y) => x==y, Bool);
  }

  [pub.to_int] (...args) { return this[proto.numeric.to_int](...args) }

  *[proto.numeric.to_int] () { return this }
}
