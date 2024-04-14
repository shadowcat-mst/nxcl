import { Value } from "./value.js";

export class Scope extends Value {
  constructor (opts) {
    let { proto } = opts;
    delete opts.proto;
    super(opts);
    this.value = Object.create(proto ?? null);
  }

  *getCellForName (cx, name) {
    let cell = this.value[name];
    if (!cell) { throw "argh" }
    return cell;
  }

  *setCellForName (cx, name, cell) {
    return this.value[name] = cell;
  }

  *getValueForName (cx, name) {
    let cell = this.value[name];
    if (!cell) { throw `no such cell ${name}` }
    return cell.value;
  }

  *setValueForName (cx, name, value) {
    let cell = this.value[name];
    if (!cell) { throw "argh" }
    if (!cell.isWriteable) { throw "ARGH" }
    return cell.value = value;
  }
}
