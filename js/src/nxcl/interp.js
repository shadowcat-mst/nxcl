import { Reader } from "./reader.js";
import { weave } from "./valuehelpers.js";
import { baseScope } from "./basescope.js";
import { Cx } from "./cx.js";

export class Interp {

  reader = new Reader();

  cx = new Cx({ scope: baseScope() });

  busy = false;

  prepareString (string) {
    let exprp = this.reader.read({ string });
    // should we be weaving here or in eval() ?
    // also once the weaver allows xcl code lolsob
    return weave(exprp, this.cx.scope);
  }

  evalString (string, evalOpts) {
    let expr = this.prepareString(string);
    return this.eval(expr, evalOpts);
  }

  startEval (expr) {
    if (this.busy) { throw "Interpreter busy" }
    this.busy = true;
    try {
      return this.cx.eval(expr);
    } finally {
      this.busy = false;
    }
  }

  async eval (expr, evalOpts) {
    let state = this.startEval(expr);
    return await this.interpret(state, evalOpts.eventHandlers);
  }

  async interpret (state, eventHandlers = {}) {
    if (this.busy) { throw "Interpreter busy" }
    this.busy = true;
    try {
      let next, nextArg = undefined;
      while (!(next = state.next(nextArg)).done) {
        let [ type, ...payload ] = next.value;
        let handler;
        if (handler = eventHandlers[type]) {
          nextArg = await handler(...payload);
        } else {
          nextArg = undefined;
        }
      }
      return next.value;
    } finally {
      this.busy = false;
    }
  }
}
