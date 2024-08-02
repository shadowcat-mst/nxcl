import { proto } from "../constants.js";
import { Value } from "../valuetypes.js";

let { CALL } = proto.core;

export let quoteKeyword = {
  __proto__: Value.prototype,
  *[CALL] (cx, args) {
    return args[0];
  }
}

export let identityKeyword = {
  __proto__: Value.prototype,
  *[CALL] (cx, args) {
    return yield* cx.eval(args[0]);
  }
}
