export class Combine {
  constructor ({ cmb, args }) {
    this.cmb = cmb;
    this.args = args;
  }

  *EVAL (cx) {
    let cmb = yield* cx.eval(this.cmb);
    return yield* cx.call(cmb, this.args);
  }

  *ASSIGN_VALUE (cx, args) {
    let cmb = yield* cx.eval(this.cmb);
    return yield* cx.send(cmb, 'ASSIGN_VIA_CALL', this.args);
  }
}
