import { proto } from "../constants.js";
import { Value, Fexpr } from "../valuetypes.js";

export let fexprKeyword = {
  __proto__: Value.prototype,
  *[proto.core.CALL] (cx, args) {
    // should also handle 'fun foo (...) {...}'
    let [ argspec, body ] = args;
    let scope = yield* cx.scope.derive();
    return new Fexpr({ scope, argspec, body });
  },
  toExternalString () { return 'Native(fun)' },
};
