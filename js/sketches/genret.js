// Can't .return() on a currently running generator so this code crashes.
// But it's a sketch, so left for future understanding.

function* f1 () {
  yield 'f1.1';
  let g, ret = (arg) => { g.return(arg) };
  let v = yield* g = f2(ret);
  yield `f2.v: ${v}`;
  yield 'f1.2';
  return 'f1.r';
}

function* f2 (ret) {
  yield 'f2.1';
  let v = yield* f3(ret);
  yield `f3.v: ${v}`;
  yield 'f2.2';
  return 'f2.r';
}

function* f3(ret) {
  yield 'f3.1';
  ret('f3.k');
  yield 'f3.2';
  return 'f3.r';
}

let g = f1();

let next;

while (!(next = g.next()).done) {
  console.log(`yield ${next.value}`);
}

console.log(`value ${next.value}`);
