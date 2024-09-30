import { proto } from "../constants.js";
import { Value } from "../valuetypes.js";

let { CALL, ASSIGN_VALUE } = proto.core;

export let equalsKeyword = new Value ({
  *[CALL] (cx, [ left, rightp ]) {
    let right = yield* cx.eval(rightp);
    return yield* cx.send(left, ASSIGN_VALUE, [ right ]);
  },
  toExternalString () { return 'Native(=)' },
});
