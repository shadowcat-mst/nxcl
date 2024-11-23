import { Message } from "../src/nxcl/valuetypes.js";
import { Interp } from "../src/nxcl/interp.js";
import { TraceBuilder } from "../src/nxcl/tracebuilder.js";
import { render, renderToString, createElement } from '../src/web/libs.js';
import { TraceNode } from '../src/web/views/trace.js';

if (import.meta.main) {
  let vnode = await run(Bun.argv[2]??'{3}()');
  console.log(renderToString(vnode, {}, { jsx: false }));
} else {
  globalThis.runXcl = run;
  globalThis.render = render;
  let showTrace_ = async function (string) {
    let view = await run(string);
    globalThis.rootView = view;
    render(createElement(view), document.body);
  };
  globalThis.showTrace = (string) => { showTrace_(string) };
}

async function run (string) {

  let interp = new Interp();

  let traceBuilder = new TraceBuilder();

  let { evalOpts } = traceBuilder;

  let result = await interp.evalString(string, evalOpts);

  return traceBuilder.buildView(TraceNode);
}
