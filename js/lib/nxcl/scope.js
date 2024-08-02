import { proto } from "./constants.js";
import { Value } from "./value.js";

export class Scope extends Value {

  cells = this.cells ?? { __proto__: null };
  methods = this.methods ?? { __proto__: null };
  ops = this.ops ?? { __proto__: null };

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
    return yield* cx.call(cell, args);
  }

  *getCellValue (cx, name) {
    return yield* this._callCell(cx, name, []);
  }

  *setCellValue (cx, name, value) {
    return yield* this._callCell(cx, name, [value]);
  }

  *setMethod (cx, type, name, value) {
    let overrides = this.methods[name] ??= [];
    // NYI: sorting by inheritance and replacing
    overrides.push([ type, value ]);
  }

  *getMethod (cx, value, name) {
    for (let [ type, override ] of this.methods[name] ?? []) {
      if (value instanceof type) return override;
    }
    return value[name];
  }

  *derive (cx) {
    let derived = {};
    for (let k of [ 'cells', 'methods', 'ops' ]) {
      derived[k] = { __proto__: this[k] };
    }
    return new this.constructor(derived);
  }

}
