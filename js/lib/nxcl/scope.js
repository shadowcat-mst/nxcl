import { proto } from "./constants.js";
import { Value } from "./value.js";

export class Scope extends Value {
  constructor (opts) {
    let { proto } = opts;
    delete opts.proto;
    super(opts);
    this.value = Object.create(proto ?? null);
  }

  *getCell (cx, name) {
    let cell = this.value[name];
    if (!cell) {
      throw `no such cell ${name}`;
    }
    return cell;
  }

  *setCell (cx, name, cell) {
    return this.value[name] = cell;
  }

  *_callCell (cx, name, args) {
    let cell = yield* this.getCell(cx, name);
    return yield* cx.send(cell, proto.core.CALL, args);
  }

  *getCellValue (cx, name) {
    return yield* this._callCell(cx, name, []);
  }

  *setCellValue (cx, name, value) {
    return yield* this._callCell(cx, name, [value]);
  }
}
