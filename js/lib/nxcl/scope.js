import { proto } from "./constants.js";
import { Value } from "./value.js";

export class Scope extends Value {

  cells = this.cells ?? {};
  methods = this.methods ?? {};
  ops = this.ops ?? {};

  *getCell (cx, name) {
    let cell = this.cells[name];
    if (!cell) {
      throw `no such cell ${name}`;
    }
    return cell;
  }

  *setCell (cx, name, cell) {
    return this.cells[name] = cell;
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
