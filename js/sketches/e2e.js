import { Message } from "../src/nxcl/valuetypes.js";
import { Interp } from "../src/nxcl/interp.js";

if (import.meta.main) {
  await run(Bun.argv[2]??'1 + 3');
} else {
  globalThis.runXcl = run;
}

async function run (string) {

  let interp = new Interp();

  let call = interp.prepareString(string);

  console.log(call.toExternalString());

  let result = await interp.eval(call, {
    eventHandlers: { trace: makeTraceHandler() },
  });

  console.log('Value:', result.toExternalString());
}

function makeTraceHandler () {
  let indent = 0, lastResult;
  return (type, payload) => {
    let indentStr = '', description;
    if (type == 'enter') {
      indentStr = '  '.repeat(indent);
      indent += 1;
      description = [ payload.callDescr(), payload.on, ...(payload.args??[]) ]
                      .map(x => (x??'').toString()).join(' ');
    } else if (type == 'leave') {
      indent -= 1;
      indentStr = '  '.repeat(indent);
      if (payload == lastResult) return;
      lastResult = payload;
      description = payload.toString();
    }
    console.log(indentStr + type, description);
  };
}
