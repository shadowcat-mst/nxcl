import { proto } from "../constants.js";
import { Val } from "./val.js";

export class Var extends Val {

  *[proto.core.CALL] (cx, args) {
    if (args.length == 1) {
      let [ arg ] = args;
      return this.value = arg;
    }
    return yield* super[proto.core.CALL](cx, args);
  }

  *[proto.core.ASSIGN_VIA_CALL] (cx, [ callargs, value ]) {
    return this.value = value;
  }
}
