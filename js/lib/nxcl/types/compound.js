export class Compound {
  constructor ({ body }) {
    this.body = body;
  }

  *EVAL (cx) {
    let [first, ...rest] = this.body;
    let res = yield* cx.eval(first);
    for (let x of rest) {
      res = yield* cx.call(res, x instanceof List ? x : [x]);
    }
    return res;
  }

  *ASSIGN_VALUE (cx, args) {
    let [first, ...rest] = this.body;
    let res = yield* cx.eval(first);
    let last = rest.at(-1);
    for (let x of rest) {
      if (x === last) break;
      res = yield* cx.call(res, x instanceof List ? x : [x]);
    }
    return yield* cx.send(res, 'ASSIGN_VIA_CALL', [
      last instanceof List ? last : [last],
      args
    ]);
  }
}
