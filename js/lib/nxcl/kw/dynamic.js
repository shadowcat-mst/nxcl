import { proto } from "../constants.js";
import { Value, Name, String } from "../valuetypes.js";

let { CALL, ASSIGN_VIA_CALL } = proto.core;

function checkArg (argp) {
  if (!((argp instanceof Name) || (argp instanceof String))) {
    throw "AAAAAAAAAAAAAA";
  }
  return argp.value;
}

export let dynamicKeyword = new Value({
  *[CALL] (cx, args) {
    let name = checkArg(args[0]);
    return cx.dynamics[name];
  },
  *[ASSIGN_VIA_CALL] (cx, args) {
    let name = checkArg(args[0][0]);
    return cx.dynamics[name] = args[1];
  },
  toExternalString () { return `Native(dynamic)` },
});
