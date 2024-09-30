import { proto, pub } from "../constants.js";
import { Value } from "../value.js";

let { EVAL, ASSIGN_VALUE } = proto.core;

export class Name extends Value {

  *[EVAL] (cx) {
    return yield* cx.scope.getCellValue(cx, this.value);
  }

  *[ASSIGN_VALUE] (cx, args) {
    // no-op assign-to-'$' ?
    return yield* cx.scope.setCellValue(cx, this.value, args[0]);
  }

  toPubSym () { return pub[this.value] }

  toExternalString () { return this.value }
}
