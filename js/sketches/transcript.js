import { Reactive } from '../src/web/reactive.js';
import { Interp } from '../src/nxcl/interp.js';
import { TraceBuilder } from '../src/nxcl/tracebuilder.js';
import { observable } from '../src/web/libs.js';

export class Transcript extends Reactive(Object, {
  set evaluations (v) { return observable(v ?? []) },
  *appendEntry ({ string }) {
    let traceBuilder = new TraceBuilder();

    let { evalOpts } = traceBuilder;

    let result = yield this.interp.evalString(string, evalOpts);

    this.evaluations.push({ code: string, trace: traceBuilder.rootNode });
  }
}) {

  interp = new Interp();

  constructor (args) { super(); Object.assign(this, args) }
}
