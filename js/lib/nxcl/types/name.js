export class Name {
  constructor ({ name }) {
    this.name = name;
  }

  *EVAL (cx) {
    return yield* cx.call(cx.scope.at(this.name));
  }

  *ASSIGN_VALUE (cx, args) {
    return yield* cx.call(cx.scope.at(this.name). args);
  }
}
