import { proto } from "../constants.js";
import { Value, List } from "../valuetypes.js";

let { CALL } = proto.core;

export class Fun extends Value {

  *[CALL] (callcx, argsp) {
    let args = yield* callcx.eval(new List({ contents: argsp }));
    return yield* callcx.send(this.fexpr, CALL, args.contents);
  }
}
