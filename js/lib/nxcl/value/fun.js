import { proto } from "../constants.js";
import { Value, List } from "../valuetypes.js";

export class Fun extends Value {

  *[proto.core.CALL] (callcx, argsp) {
    let args = yield* callcx.eval(new List({ contents: argsp }));
    return yield* callcx.send(this.fexpr, proto.core.CALL, args.contents);
  }
}
