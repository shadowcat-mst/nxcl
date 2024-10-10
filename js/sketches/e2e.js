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
    let [ e1, e2, payload ] = next.value;
    if (e1 !== 'trace') {
      continue;
    }
    let indentStr = '', description;
    if (e2 == 'enter') {
      indentStr = '  '.repeat(indent);
      indent += 1;
      let message = new Message(payload);
      description = [ message.callDescr(), message.on, ...(message.args??[]) ]
                      .map(x => (x??'').toString()).join(' ');
    } else if (e2 == 'leave') {
      indent -= 1;
      indentStr = '  '.repeat(indent);
      if (payload == lastResult) continue;
      lastResult = payload;
      description = payload.toString();
    }
    console.log(indentStr + e2, description);
  }
  return next.value;
}
