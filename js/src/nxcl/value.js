import { proto } from "./constants.js";

let { EVAL, DOT } = proto.core;

export const _Message = {};

export class Value {
  constructor (opts) {
    Object.assign(this, opts);
  }

  *[EVAL] () { return this }

  *[DOT] (cx, [ messagep ]) {
    return new _Message.$value({
      call: messagep.toPubSym(),
      on: this,
      withArgs: [],
    });
  }

  toString () { return this.toExternalString() }

  toExternalString () {
    return (
      this.constructor.name + '(' + this.valueToExternalString() + ')'
    );
  }

  valueToExternalString (sep = ', ') {
    if (Object.hasOwn(this, 'value')) return this.value.toString();
    if (Object.hasOwn(this, 'contents')) {
      return this.contents.map(v => v.toExternalString()).join(sep);
    }
    return "!.value&!.contents&WTF";
  }
}
