import { proto } from "./constants.js";

export class Cx {

  constructor (args) {
    Object.assign(this, args);
  }

  eval (val) {
    return val[proto.core.EVAL](this);
  }

  call (val, args) {
    return val[proto.core.CALL](this, args);
  }

  send (val, messageId, args) {
    if (!val[messageId]) {
      // messageId may be a Symbol
      throw `No such method ${messageId.toString()} on ${val}`;
    }
    return val[messageId](this, args);
  }
}
