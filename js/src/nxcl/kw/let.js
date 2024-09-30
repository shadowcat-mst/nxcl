import { proto } from "../constants.js";
import { Name, Value, Val, Var, Call } from "../valuetypes.js";

let { CALL, ASSIGN_VIA_CALL, ASSIGN_VALUE } = proto.core;

export function* withAssigner (outerCx, CellType) {
  let outerScope = outerCx.scope;
  let scope = yield* outerScope.derive();
  function* assignValue (cx, [ value ]) {
    yield* outerScope.setCell(outerCx, this.value, new CellType({ value }));
    return value;
  }
  yield* scope.setMethod(outerCx, Name, ASSIGN_VALUE, assignValue);
  return new outerCx.constructor({ scope });
}

const expr = list => list.length > 1 ? new Call({ contents: list }) : list[0];

const makeKeyword = (name, CellType) => { return new Value({
  *[CALL] (outerCx, args) {
    let innerCx = yield* withAssigner(outerCx, CellType);
    return yield* innerCx.eval(expr(args));
  },
  *[ASSIGN_VIA_CALL] (outerCx, [ args, value ]) {
    let innerCx = yield* withAssigner(outerCx, CellType);
    return yield* innerCx.send(expr(args), ASSIGN_VALUE, [ value ]);
  },
  toExternalString () { return `Native(${name})` },
})};

export let letKeyword = makeKeyword('let', Val);
export let varKeyword = makeKeyword('var', Var);
