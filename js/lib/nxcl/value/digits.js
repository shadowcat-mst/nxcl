import { proto } from "../constants.js";
import { Value } from "../value.js";
import { Int } from "./int.js";

export class Digits extends Value {

  *[proto.numeric.plus] (cx, args) {
    let int = yield* cx.send(this, proto.numeric.to_int);
    return yield* cx.send(int, proto.numeric.plus, args);
  }

  *[proto.numeric.to_int] () {
    let value = parseInt(this.value);
    return new Int({ ...this, value })
  }
}
