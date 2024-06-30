import { proto } from "../constants.js";
import { Name, Value, Val, Var, Call } from "../valuetypes.js";

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

const makeKeyword = (name, CellType) => { return {
  __proto__: Value.prototype,
  *[proto.core.CALL] (outerCx, args) {
    let innerCx = yield* withAssigner(outerCx, CellType);
    return yield* innerCx.eval(expr(args));
  },
  *[proto.core.ASSIGN_VIA_CALL] (outerCx, [ args, value ]) {
    let innerCx = yield* withAssigner(outerCx, CellType);
    return yield* innerCx.send(expr(args), proto.core.ASSIGN_VALUE, [ value ]);
  },
  toExternalString () { return `Native(${name})` },
} };

export let letKeyword = makeKeyword('let', Val);
export let varKeyword = makeKeyword('var', Var);
