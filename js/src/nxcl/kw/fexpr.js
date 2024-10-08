import { proto } from "../constants.js";
import { Value, Fexpr, Fun } from "../valuetypes.js";

let { CALL } = proto.core;

function _Fun (...args) {
  return new Fun({ fexpr: new Fexpr(...args) });
}

const makeKeyword = (name, Ftype) => { return new Value({
  *[CALL] (cx, args) {
    // should also handle 'fun/fexpr foo (...) {...}'
    let [ argspec, body ] = args;
    let scope = yield* cx.scope.derive();
    return new Ftype({ scope, argspec, body });
  },
  toExternalString () { return `Native(${name})` },
})};

export let fexprKeyword = makeKeyword('fexpr', Fexpr);
export let funKeyword = makeKeyword('fun', _Fun);
