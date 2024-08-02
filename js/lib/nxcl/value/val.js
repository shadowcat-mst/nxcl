import { proto } from "../constants.js";
import { Value } from "../value.js";

let { CALL } = proto.core;

export class Val extends Value {

  *[CALL] (cx, args) {
    if (args.length) throw "Val cell is read only";
    return this.value;
  }
}
