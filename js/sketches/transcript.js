import { Reactive } from '../src/web/reactive.js'
import { Interp } from '../src/nxcl/interp.js'
import { TraceBuilder } from '../src/nxcl/tracebuilder.js'
import { mobx } from '../src/web/libs.js'
import { ensureHiddenProp } from '../src/util/objects.js'

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
  *recalculate () { return yield* this.recalculate_() }
}) {

  constructor (args) {
    super()
    Object.assign(this, args)
    this.recalculate()
  }

  *recalculate_ () {
    const runner = new TranscriptRunner()
    for (const ev of this.evaluations) {
      const trace = yield runner.run(ev.code)
      ev.trace = trace
      yield
    }
    // reschedule self on change
    const $reaction = 'recalculate$reaction';
    const reaction = ensureHiddenProp(
      this, $reaction,
      () => new mobx.Reaction(
        [ this.constructor.name, $reaction ].join('().'),
        () => this.recalculate()
      )
    )
    reaction.track(() => this.evaluations.map(v => v.code))
  }
}
