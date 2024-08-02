import { proto } from "../constants.js";
import { Val } from "./val.js";

let { CALL, ASSIGN_VIA_CALL } = proto.core;

export class Var extends Val {

  *[CALL] (cx, args) {
    if (args.length == 1) {
      let [ arg ] = args;
      return this.value = arg;
    }
    return yield* super[CALL](cx, args);
  }

  *[ASSIGN_VIA_CALL] (cx, [ callargs, value ]) {
    return this.value = value;
  }
}
