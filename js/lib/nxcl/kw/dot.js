import { proto } from "../constants.js";
import { Value, Message } from "../valuetypes.js";

let { CALL, DOT } = proto.core;

export let dotKeyword = {
  __proto__: Value.prototype,
  *[CALL] (cx, args) {
    if (args.length == 1) {
      // .name
      return new Message({
        call: args[0].toPubSym(),
      });
    }
    if (args.length == 2) {
      let [ objp, messagep ] = args;
      let obj = yield* cx.eval(objp);
      return yield* cx.send(obj, DOT, [ messagep ]);
    }
    throw "Eh? (dotKeyword)";
  },
  toExternalString () { return 'Native(.)' },
};
