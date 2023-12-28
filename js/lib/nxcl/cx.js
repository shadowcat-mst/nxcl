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
    return val[messageId](this, args);
  }
}
