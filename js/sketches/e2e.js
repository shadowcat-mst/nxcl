import { proto } from "../lib/nxcl/constants.js";
import { Message, Int, Call, Name, Val } from "../lib/nxcl/valuetypes.js";
import { Cx } from "../lib/nxcl/cx.js";
import { Scope } from "../lib/nxcl/scope.js";
import { Reader } from "../lib/nxcl/reader.js";

let reader = new Reader();

// let call = reader.read({ string: "+ 2 x" });
let call = reader.read({ string: "+ x 2" });

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
