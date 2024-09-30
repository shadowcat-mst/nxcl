import { Name, Call } from "./valuetypes.js";

function findBest (haystack, isOp) {
  let ends = { 0: true, [haystack.length - 1]: true };
  let best = [ ...haystack.keys() ]
    .filter(idx => (!ends[idx]) && (haystack[idx] instanceof Name))
    .flatMap((idx, op) => (
      (op = isOp(haystack[idx]))
        ? [{ ...op, idx }]
      : []
    ))
    .reduce(
       (a, v) => (v.precedence < a.precedence ? v : a),
       { precedence: Number.MAX_SAFE_INTEGER },
    );
  if (best.idx) return best;
  return null;
}

export function rewriteOps (orig, isOp) {

  if (!Object.hasOwn(orig, 'contents')) return orig;

  let recurse = v => rewriteOps(v, isOp);

  let { contents, constructor } = orig;

  if (contents.length < 3) {
    return new constructor({
      ...orig,
      contents: contents.map(recurse)
    });
  }

  let bestOp = findBest(contents, isOp);

  if (!bestOp) {
    return new constructor({ ...orig, contents: contents.map(recurse) });
  }

  let { idx, tightLeft, tightRight } = bestOp;

  let [ before, op, after ] = [
    contents.slice(0, idx),
    contents.at(idx),
    contents.slice(idx+1),
  ];

  let lhsp = tightLeft ? [ before.pop() ] : before.splice(0);
  let rhsp = tightRight ? [ after.shift() ] : after.splice(0);

  let [ lhs, rhs ] = [ lhsp, rhsp ].map(
    p => p.length == 1 ? p[0] : new constructor({ contents: p })
  );

  let opCall = new Call({ contents: [ op, recurse(lhs), recurse(rhs) ] });

  if (!before.length && !after.length) return opCall;
  return new constructor({
    contents: [ ...before.map(recurse), opCall, ...after.map(recurse) ]
  });
}
