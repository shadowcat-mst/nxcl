import { proto } from "../constants.js";
import { Name, Value, Val, Call } from "../valuetypes.js";

function* withAssigner (outerCx, CellType) {
  let outerScope = outerCx.scope;
  let scope = yield* outerScope.derive();
  function* ASSIGN_VALUE (cx, [ value ]) {
    yield* outerScope.setCell(outerCx, this.value, new CellType({ value }));
    return value;
  }
  yield* scope.setMethod(outerCx, Name, proto.core.ASSIGN_VALUE, ASSIGN_VALUE);
  return new outerCx.constructor({ scope });
}

const expr = list => list.length > 1 ? new Call({ contents: list }) : list[0];

export let letKeyword = {
  __proto__: Value.prototype,
  *[proto.core.CALL] (outerCx, args) {
    let innerCx = yield* withAssigner(outerCx, Val);
    return yield* innerCx.eval(expr(args));
  },
  *[proto.core.ASSIGN_VIA_CALL] (outerCx, [ args, value ]) {
    let innerCx = yield* withAssigner(outerCx, Val);
    return yield* innerCx.send(expr(args), proto.core.ASSIGN_VALUE, [ value ]);
  },
  toExternalString () { return 'Native(let)' },
};
