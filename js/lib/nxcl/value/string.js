import { proto } from "../constants.js";
import { Value } from "../value.js";

export class String extends Value {
  // this doesn't escape but getting the contents of the '...' to here from
  // the reader doesn't unescape either; this is basically temporary NYI
  toExternalString () { return "'" + this.value + "'" }
}
