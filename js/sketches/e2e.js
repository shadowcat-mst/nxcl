import { proto } from "../src/nxcl/constants.js";
import { Message, Int, Call, Name, Val } from "../src/nxcl/valuetypes.js";
import { Cx } from "../src/nxcl/cx.js";
import { Scope } from "../src/nxcl/scope.js";
import { baseScope } from "../src/nxcl/basescope.js";
import { Reader } from "../src/nxcl/reader.js";
import { rewriteOps } from "../src/nxcl/valuehelpers.js"

if (import.meta.main) {
  run(Bun.argv[2]??'1 + 3');
} else {
  globalThis.runXcl = run;
}

function run (string) {

  let reader = new Reader();

  let callp = reader.read({ string });

  console.log(callp.toExternalString());

  let scope = baseScope();

  let isOp = cand => (cand instanceof Name) ? scope.ops[cand.value] : null;

  let call = rewriteOps(callp, isOp);

  console.log(call.toExternalString());

  let cx = new Cx({ scope });

  let result = cx.eval(call, []);

  let last = exhaust(result);

  console.log('Value:', last.toExternalString());
}

function exhaust (result) {
  let indent = 0;
  let next, lastResult;
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
      if (rest[0] == lastResult) continue;
      lastResult = rest[0];
    }
    console.log(indentStr + first, rest.map(x => (x??'').toString()).join(', '));
  }
  return next.value;
}
