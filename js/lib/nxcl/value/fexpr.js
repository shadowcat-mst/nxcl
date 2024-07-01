import { proto } from "../constants.js";
import { Value, Val, List } from "../valuetypes.js";
import { withAssigner } from "../kw/let.js";

export class Fexpr extends Value {

  *[proto.core.CALL] (callcx, args) {
    let scope = yield* this.scope.derive();
    yield* scope.setCell(callcx, 'callcx', new Val(callcx));
    let cx = yield* callcx.derive({ scope });

    let acx = yield* withAssigner(cx, Val);
    let arglist = new List({ contents: args });
    yield* acx.send(this.argspec, proto.core.ASSIGN_VALUE, [ arglist ]);

    return yield* cx.send(this.body, proto.core.CALL, []);
  }
}
