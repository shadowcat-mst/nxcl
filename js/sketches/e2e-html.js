import { Message } from "../src/nxcl/valuetypes.js";
import { Interp } from "../src/nxcl/interp.js";
import { TraceNode } from "../src/web/views/tracenode.js";
import { TraceBuilder } from "../src/nxcl/tracebuilder.js";
import render from 'preact-render-to-string/jsx';

if (import.meta.main) {
  let vnode = await run(Bun.argv[2]??'1 + 3');
  console.log(render(vnode, {}, { jsx: false }));
} else {
  globalThis.runXcl = run;
}

async function run (string) {

  let interp = new Interp();

  let traceBuilder = new TraceBuilder();

  let { evalOpts } = traceBuilder;

  let result = await interp.evalString(string, evalOpts);

  return traceBuilder.buildView(TraceNode).render();
}
