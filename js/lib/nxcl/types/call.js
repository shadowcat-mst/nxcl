export class Call {
  constructor ({ body }) {
    this.body = body;
  }

  *EVAL (cx) {
    let runcx = cx.enter(this);
    let res;
    for (let part of this.body) {
      res = yield* runcx.eval(part);
    }
    return res;
  }
}
