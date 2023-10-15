export class Block {
  constructor ({ body }) {
    this.body = body;
  }

  *CALL (cx, args) {
    let locals = args.length
      ? { this: new Val(args[0]) }
      : {};
    let runcx = cx.enter(this, locals);
    return yield* runcx.eval(this.body);
  }
}
