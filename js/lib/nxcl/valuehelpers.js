import { Name } from "./value/name.js";
import { Call } from "./value/call.js";

export function *rewriteOps (orig, isOp, recurse) {
  let { value, constructor } = orig;
  if (value.length < 3) return orig;
  let bestOp;
  let ends = { 0: true, [value.length - 1]: true };
  for (let idx in value) {
    if (idx in ends) continue;
    let el = value[idx];
    if (el instanceof Name) {
      let opInfo;
      if (opInfo = isOp(el)) {
        if (!bestOp || opInfo.precedence < bestOp.opInfo.precedence) {
          bestOp = { idx, opInfo };
        }
      }
    }
  }
  if (!bestOp) return orig;
  let { idx, opInfo } = bestOp;
  let [ before, op, after ] = [
    value.slice(0, idx),
    value.at(idx),
    value.slice(idx+1),
  ];
  let lhsp = opInfo.tightLeft ? [ before.pop() ] : before.splice(0);
  let rhsp = opInfo.tightRight ? [ after.shift() ] : after.splice(0);
  let [ lhs, rhs ] = [ lhsp, rhsp ].map(
    p => p.length == 1 ? p[0] : new constructor(p)
  );
  let opCall = new Call([ op, recurse(lhs), recurse(rhs) ]);
  if (!before && !after) return opCall;
  return new constructor([ ...recurse(before), opCall, ...recurse(after) ]);
}
