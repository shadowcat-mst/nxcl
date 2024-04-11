import { proto, pub } from "../constants.js";
import { Value } from "../value.js";

export class Bool extends Value {

  [pub.to_bool] (...args) { return this[proto.bool.to_bool](...args) }

  *[proto.bool.to_bool] () { return this }

  [pub.ifelse] (...args) { return this[proto.bool.ifelse](...args) }

  *[proto.bool.ifelse] (cx, args) {
    let expr = args[0+!this.value]; // true -> 0, false -> 1
    return yield* cx.eval(expr);
  }

  *[proto.bool.not] () { return new this.constructor({ value: this.value }) }

  static *[pub.true] () { return new this({ value: true }) }
  static *[pub.false] () { return new this({ value: false }) }
}
