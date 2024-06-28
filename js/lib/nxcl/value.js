import { proto } from "./constants.js";

export const _Message = {};

export class Value {
  constructor (opts) {
    Object.assign(this, opts);
  }

  *[proto.core.EVAL] () { return this }

  *[proto.core.DOT] (cx, [ messagep ]) {
    return new _Message.$value({
      call: messagep.toPubSym(),
      on: this,
      withArgs: [],
    });
  }

  toString () { return this.toExternalString() }

  toExternalString () {
    return (
      this.constructor.name + '.new(' + this.valueToExternalString() + ')'
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
