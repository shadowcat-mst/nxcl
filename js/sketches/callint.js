import { proto } from "../lib/nxcl/constants.js";
import { Message, Int, Call } from "../lib/nxcl/valuetypes.js";
import { Cx } from "../lib/nxcl/cx.js";

let two = new Int({ value: 2 });
let three = new Int({ value: 3 });

let cx = new Cx({});

let message = new Message({
  message: proto.numeric.plus,
  args: []
});

let call = new Call({
  contents: [ message, two, three ],
});

let result = cx.eval(call);

let next;
while (!(next = result.next()).done) {
  console.log('Yield: ', next.value);
}
console.log('Value: ', next.value);
