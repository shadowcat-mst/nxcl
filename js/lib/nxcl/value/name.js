import { proto } from "../constants.js";
import { Value } from "../value.js";

export class Name extends Value {

  *[proto.core.EVAL] (cx) {
    return yield* cx.scope.getValueForName(cx, this.value);
  }

  *[proto.core.ASSIGN_VALUE] (cx, args) {
    // no-op assign-to-'$' ?
    return yield* cx.scope.setValueForName(cx, this.value, args[0]);
  }
}
