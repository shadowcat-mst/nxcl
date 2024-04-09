import { proto, pub } from "../constants.js";
import { Value } from "../value.js";
import { Int } from "./int.js";

export class Digits extends Value {

  [pub.plus] (...args) { return this[proto.numeric.plus](...args) }

  *[proto.numeric.plus] (cx, args) {
    let int = yield* cx.send(this, proto.numeric.to_int);
    return yield* cx.send(int, proto.numeric.plus, args);
  }

  [pub.minus] (...args) { return this[proto.numeric.minus](...args) }

  *[proto.numeric.minus] (cx, args) {
    let int = yield* cx.send(this, proto.numeric.to_int);
    return yield* cx.send(int, proto.numeric.minus, args);
  }

  [pub.to_int] (...args) { return this[proto.numeric.to_int](...args) }

  *[proto.numeric.to_int] () {
    let value = parseInt(this.value);
    return new Int({ ...this, value })
  }
}
