import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Val extends Value {

  *[proto.core.CALL] (cx, args) {
    if (args.length) throw "ARGH";
    return this.value;
  }
}
