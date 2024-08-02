import { proto } from "../lib/nxcl/constants.js";
import { Message, Int, Call, Name, Val } from "../lib/nxcl/valuetypes.js";
import { Cx } from "../lib/nxcl/cx.js";
import { Scope } from "../lib/nxcl/scope.js";
import { baseScope } from "../lib/nxcl/basescope.js";
import { Reader } from "../lib/nxcl/reader.js";
import { rewriteOps } from "../lib/nxcl/valuehelpers.js"

let reader = new Reader();

let callp = reader.read({ string: Bun.argv[2]??'1 + 3' });

console.log(callp.toExternalString());

let scope = baseScope();

let isOp = cand => (cand instanceof Name) ? scope.ops[cand.value] : null;

let call = rewriteOps(callp, isOp);

console.log(call.toExternalString());

let cx = new Cx({ scope });

/*
exhaust(
  scope.setMethod(
    cx, Int, proto.numeric.plus,
    function* () { return new Int({ value: 42 }) },
  )
);
*/

// ?? (reinstated ESeq eval, maybe a good idea, maybe not

let result = cx.eval(call, []);

function exhaust (result) {
  let indent = 0;
  let next;
  while (!(next = result.next()).done) {
    let [ first, ...rest ] = next.value;
    if (first == '+') {
      // method name fuckery
      rest[1] = rest[1].description
            .replace('xcl.protocol.', '')
            .replace(/\./, '::');
    }
    let indentStr = '';
    if (first == '+') {
      indentStr = '  '.repeat(indent);
      indent += 1;
    } else if (first == '-') {
      indent -= 1;
      indentStr = '  '.repeat(indent);
    }
    console.log(indentStr + first, rest.map(x => (x??'').toString()).join(', '));
  }
  return next.value;
}

let last = exhaust(result);

console.log('Value:', last.toExternalString());
