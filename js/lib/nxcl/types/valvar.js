export class Val {
  constructor ({ value }) {
    this.value = value;
  }

  *CALL (cx) {
    return this.value;
  }
}

export class Var extends Val {

  *ASSIGN_VIA_CALL(cx, [ call_args, to_assign ]) {
    this.value = yield* to_assign.at(cx, 0);
  }
}
