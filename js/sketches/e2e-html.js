import { Interp } from "../src/nxcl/interp.js";
import { VFrame } from "../src/web/views/vframe.js";
import { TraceBuilder } from "../src/nxcl/tracebuilder.js";
import { preact } from '../src/web/libs.js';
import { TraceNode } from '../src/web/views/trace.js';

if (import.meta.main) {
  let vframe = new VFrame();
  vframe.content = await run(Bun.argv[2]??'{3}()');
  console.log(preact.renderToString(preact.h(vframe)))
} else {
  let showTrace_ = async function (string) {
    document.body.vframe.content = await run(string);
  };
  globalThis.showTrace = (string) => { showTrace_(string) };
}

async function run (string) {

  let interp = new Interp();

  let traceBuilder = new TraceBuilder();

  let { evalOpts } = traceBuilder;

  let result = await interp.evalString(string, evalOpts);

  return new TraceNode({ model: traceBuilder.rootNode });
}
