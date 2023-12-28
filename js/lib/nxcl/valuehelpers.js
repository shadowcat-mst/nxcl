import { metaKey } from "./constants.js";
import { Name } from "value/name.js";
import { Call } from "value/call.js";

export function *rewriteOps (cx, orig) {
  let { data, constructor } = orig;
  if (data.length < 3) return orig;
  let opCount = 0, bestOp;
  let ends = { 0: true, [data.length - 1]: true };
  for (let idx in data) {
    if (idx in ends) continue;
    let el = data[idx];
    if (el instanceof Name) {
      let val = yield* cx.scope.maybeGetValue(cx, el);
      let opInfo;
      if (val && (opInfo = val.metadata[metaKey.opInfo])) {
        opCount++;
        if (!bestOp || opInfo.precedence < bestOp.opInfo.precedence) {
          bestOp = { idx, opInfo };
        }
      }
    }
  }
  if (!bestOp) return orig;
  let { idx, opInfo } = bestOp;
  let [ before, op, after ] = [
    data.slice(0, idx),
    data.at(idx),
    data.slice(idx+1),
  ];
  let lhsp = opInfo.tightLeft ? [ before.pop() ] : before.splice(0);
  let rhsp = opInfo.tightRight ? [ after.shift() ] : after.splice(0);
  let [ lhs, rhs ] = [ lhsp, rhsp ].map(
    p => p.length == 1 ? p[0] : new constructor(p)
  );
  let opCall = new Call([ op, lhs, rhs ]);
  if (!before && !after) return opCall;
  let ret = new constructor([ ...before, opCall, ...after ]);
  if (opCount == 1) return ret;
  return rewriteOps(cx, ret);
}
