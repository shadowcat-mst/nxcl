import { proto } from "constants.js";

export class Value {
  constructor (data, metadata) {
    this.data = data;
    this.metadata = { __proto__: null, ...(metadata ?? {}) };
  }

  *[proto.core.EVAL] (cx) { return this }
}
