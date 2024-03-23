import { proto } from "../lib/nxcl/constants.js";
import { Message, Int, Call, Name, Val } from "../lib/nxcl/valuetypes.js";
import { Cx } from "../lib/nxcl/cx.js";
import { Scope } from "../lib/nxcl/scope.js";

let two = new Int({ value: 2 });
let three = new Int({ value: 3 });

let plus = new Message({
  message: proto.numeric.plus,
  args: []
});

let scopeData = {
  '+': new Val({ value: plus }),
  'three': new Val({ value: three }),
};

let cx = new Cx({ scope: new Scope({ proto: scopeData }) });

let call = new Call({
  contents: [ new Name({ value: '+' }), two, new Name({ value: 'three' }) ],
});

let result = cx.eval(call);

let next;
while (!(next = result.next()).done) {
  console.log('Yield:', next.value);
}
console.log('Value:', next.value.value);
