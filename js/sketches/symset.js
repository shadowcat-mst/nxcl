"use strict";

let { log } = console;

function symSet(prefix) {
  let set, proxy = new Proxy({}, {
    get (target, prop, receiver) {
      return set[prop] = Symbol(`${prefix}.${prop}`);
    }
  });
  return set = Object.create(proxy);
}

let mySet = symSet('foo');

log(mySet.bar);

log(mySet.spoon == mySet.spoon);

log(mySet);
