import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Block extends Value {

  *[proto.core.CALL] (cx, args) {
    let ecx = yield* cx.derive();
    return yield* ecx.call(this.contents[0], []);
  }
}
