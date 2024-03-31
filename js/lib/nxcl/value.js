import { proto } from "./constants.js";

export class Value {
  constructor (args) {
    Object.assign(this, args);
  }

  *[proto.core.EVAL] () { return this }

  toExternalString () {
    return this.constructor.name + '(' + this.valueToExternalString() + ')';
  }

  valueToExternalString () {
    if (Object.hasOwn(this, 'value')) return this.value.toString();
    if (Object.hasOwn(this, 'contents')) {
      return this.contents.map(v => v.toExternalString()).join(', ');
    }
    throw "Neither .value nor .contents present on Value object; WTF?!";
  }
}
