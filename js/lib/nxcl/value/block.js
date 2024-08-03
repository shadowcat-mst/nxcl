import { proto } from "../constants.js";
import { Value, Val, Call } from "../valuetypes.js";

let { CALL } = proto.core;

export class Block extends Value {

  *[CALL] (cx, args) {
    let scope = yield* cx.scope.derive();
    let deferQueue = [];
    yield* scope.setCell(cx, 'defer', new Val({ value: new Value({
      *[CALL] (cx, args) {
        deferQueue.unshift([ cx.scope, new Call({ contents: args }) ]);
      },
    })}));
    let ecx = yield* cx.derive({ scope });
    try {
      return yield* ecx.call(this.contents[0], []);
    } finally {
      for (let [ scope, call ] of deferQueue) {
        yield* (yield* cx.derive({ scope })).eval(call);
      }
    }
  }
}
