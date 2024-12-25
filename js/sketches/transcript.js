import { Reactive } from '../src/web/reactive.js'
import { Interp } from '../src/nxcl/interp.js'
import { TraceBuilder } from '../src/nxcl/tracebuilder.js'
import { mobx } from '../src/web/libs.js'

class TranscriptRunner {

  interp = new Interp()

  async run (string) {
    const traceBuilder = new TraceBuilder()

    const { evalOpts } = traceBuilder

    await this.interp.evalString(string, evalOpts)

    return traceBuilder.rootNode
  }
}

export class Transcript extends Reactive(Object, {
  set evaluations (v) { return mobx.observable(v ?? []) },
  *recalculate () {
    const runner = new TranscriptRunner()
    for (const ev of this.evaluations) {
      const trace = yield runner.run(ev.code)
      ev.trace = trace
      yield
    }
  },
}) {

  constructor (args) {
    super()
    Object.assign(this, args)
    this.recalculate()
  }
}
