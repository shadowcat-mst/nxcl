import { proto } from "../constants.js";
import { Val } from "./val.js";

export class Var extends Val {

  isWriteable = true;

  *[proto.core.CALL] (cx, args) {
    if (args.length == 1) {
      let [ arg ] = args;
      return this.value = arg;
    }
    return super[proto.core.CALL](cx, args);
  }

  *[proto.core.ASSIGN_VALUE] (cx, [ value ]) {
    return this.value = args[0];
  }
}
