export function lazyObject (propBuilder) {
  let obj, proxy = new Proxy({}, {
    get (target, prop, receiver) {
      return obj[prop] = propBuilder(prop);
    }
  });
  return obj = Object.create(proxy);
}

// expects plain func, will not copy properties from *it*

export function lazyFunctionObject (func, propBuilder) {
  let obj = (...args) => func(...args);
  let proto = Object.getPrototypeOf(func);
  let proxy = new Proxy(proto, {
    get (target, prop, receiver) {
      if (prop in receiver) return receiver[prop];
      return obj[prop] = propBuilder(prop);
    }
  });
  Object.setPrototypeOf(obj, proxy);
  return obj;
}
