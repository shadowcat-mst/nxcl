export class Cx {
  eval (val) {
    return val.EVAL(this);
  }
  call (val, args) {
    return val.CALL(this, args);
  }
  send (val, name, args) {
    return val[name](this, args);
  }
}
