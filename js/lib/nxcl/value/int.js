import { proto } from "../constants.js";
import { Value } from "../value.js";

class Int extends Value {

  *[proto.numeric.plus] (cx, args) {
    let sum = args.reduce((a, b) => a + b.data, this.data);
    return new this.constructor({ ...this, data: sum });
  }

  *[proto.numeric.to_int] () { return this }
}
