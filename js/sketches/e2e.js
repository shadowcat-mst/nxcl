import { proto } from "../lib/nxcl/constants.js";
import { Message, Int, Call, Name, Val } from "../lib/nxcl/valuetypes.js";
import { Cx } from "../lib/nxcl/cx.js";
import { Scope } from "../lib/nxcl/scope.js";
import { Reader } from "../lib/nxcl/reader.js";
import { rewriteOps } from "../lib/nxcl/valuehelpers.js"

let reader = new Reader();

let callp = reader.read({ string: Bun.argv[2]??'1 + 3' });

console.log(callp.toExternalString());

let isOp; {
  let ops = { '+': { precedence: 0 } };
  isOp = cand => (cand instanceof Name) ? ops[cand.value] : null;
}

let call = rewriteOps(callp, isOp);

console.log(call.toExternalString());

let three = new Int({ value: 3 });

let plus = new Message({
  message: proto.numeric.plus,
  args: []
});

let scopeData = {
  '+': new Val({ value: plus }),
  'x': new Val({ value: three }),
};

let cx = new Cx({ scope: new Scope({ proto: scopeData }) });

let result = cx.eval(call);

let next;
while (!(next = result.next()).done) {
  console.log('Yield:', next.value);
}
console.log('Value:', next.value.value);
