import { proto } from "./constants.js";

export class Value {
  constructor (args) {
    Object.assign(this, args);
  }

  *[proto.core.EVAL] () { return this }
}
