import { Message } from "../src/nxcl/valuetypes.js";
import { Interp } from "../src/nxcl/interp.js";
import { TraceNode } from "../src/web/views/tracenode.js";
import render from 'preact-render-to-string/jsx';

class TraceNodeModel {

  // has: message, value, parent, children

  children = [];

  constructor (args) {
    Object.assign(this, args);
  }

  addChildFor (message) {
    let child = new this.constructor({ message, parent: this });
    this.children.push(child);
    return child;
  }

  completeNode (value) {
    this.value = value;
    return this.parent;
  }

}

if (import.meta.main) {
  await run(Bun.argv[2]??'1 + 3');
} else {
  globalThis.runXcl = run;
}

async function run (string) {

  let interp = new Interp();

  let traceRoot = new TraceNodeModel();

  let result = await interp.evalString(string, {
    eventHandlers: { trace: makeTraceHandler(traceRoot) },
  });

  let vnode = (new TraceNode({ model: traceRoot.children[0] })).render();

  console.log(render(vnode, {}, { jsx: false }));
}

function makeTraceHandler (traceRoot) {

  let currentNode = traceRoot;

  return (type, payload) => {
    if (type == 'enter') {
      currentNode = currentNode.addChildFor(payload);
    } else if (type == 'leave') {
      currentNode = currentNode.completeNode(payload);
    }
  };
}
