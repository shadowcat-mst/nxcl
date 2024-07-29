import { proto } from "../constants.js";
import { Value } from "../valuetypes.js";

export let equalsKeyword = {
  __proto__: Value.prototype,
  *[proto.core.CALL] (cx, [ left, rightp ]) {
    let right = yield* cx.eval(rightp);
    return yield* cx.send(left, proto.core.ASSIGN_VALUE, [ right ]);
  },
  toExternalString () { return 'Native(=)' },
};
