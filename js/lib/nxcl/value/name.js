import { proto, pub } from "../constants.js";
import { Value } from "../value.js";

export class Name extends Value {

  *[proto.core.EVAL] (cx) {
    return yield* cx.scope.getCellValue(cx, this.value);
  }

  *[proto.core.ASSIGN_VALUE] (cx, args) {
    // no-op assign-to-'$' ?
    return yield* cx.scope.setCellValue(cx, this.value, args[0]);
  }

  toPubSym () { return pub[this.value] }
}
