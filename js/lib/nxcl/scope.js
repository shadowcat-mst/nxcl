import { Value } from "./value.js";

export class Scope extends Value {
  constructor (args) {
    let { proto } = args;
    delete args.proto;
    Object.assign(this, args);
    this.data = Object.create(proto ?? null);
  }

  *getValueForName (cx, name) {
    let cell = this.data[name];
    if (!cell) { throw "argh" }
    return cell.value;
  }

  *setValueForName (cx, name, value) {
    let cell = this.data[name];
    if (!cell) { throw "argh" }
    if (!cell.isWriteable) { throw "ARGH" }
    return cell.value = value;
  }
}
