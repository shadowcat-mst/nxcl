import { Value } from "./value.js";

export class Scope extends Value {
  constructor (args) {
    let { proto } = args;
    delete args.proto;
    Object.assign(this, args);
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
    if (!cell) { throw "argh" }
    return cell.value;
  }

  *setValueForName (cx, name, value) {
    let cell = this.value[name];
    if (!cell) { throw "argh" }
    if (!cell.isWriteable) { throw "ARGH" }
    return cell.value = value;
  }
}
