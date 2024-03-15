import { proto } from "../lib/nxcl/constants.js";
import { Message, Int } from "../lib/nxcl/valuetypes.js";
import { Cx } from "../lib/nxcl/cx.js";

let two = new Int({ value: 2 });
let three = new Int({ value: 3 });

let cx = new Cx({});

let message = new Message({
  message: proto.numeric.plus,
  args: []
});

let result = cx.call(message, [ two, three ]);

let next;
while (!(next = result.next()).done) {
  console.log('Yield: ', next.value);
}
console.log('Value: ', next.value);
