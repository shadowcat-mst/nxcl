import { proto } from "../constants.js";
import { Value } from "../value.js";

let { CALL, EVAL, ASSIGN_VALUE, ASSIGN_VIA_CALL } = proto.core;

export class Call extends Value {

  *[CALL] (cx, args) {
    let call = !args.length ? this : new this.constructor({
      ...this, contents: [ ...this.contents, ...args ],
    });
    return yield* cx.eval(call);
  }

  *[EVAL] (cx) {
    let [ combinerp, ...args ] = this.contents;
    let combiner = yield* cx.eval(combinerp);
    return yield* cx.call(combiner, args);
  }

  *[ASSIGN_VALUE] (cx, [ v ]) {
    let [ combinerp, ...callargs ] = this.contents;
    let combiner = yield* cx.eval(combinerp);
    let args = [ callargs, v ];
    return yield* cx.send(combiner, ASSIGN_VIA_CALL, args);
  }

  toExternalString () { return '[ ' + this.valueToExternalString(' ') + ' ]' }
}
