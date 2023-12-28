export class Scope extends Value {
  constructor ({ proto }, metadata) {
    this.data = Object.create(proto === undefined ? null : proto);
    this.metadata
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
