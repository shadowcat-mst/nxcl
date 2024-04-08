function lazyObject(builder) {
  let obj, proxy = new Proxy({}, {
    get (target, prop, receiver) {
      return obj[prop] = builder(prop);
    }
  });
  return obj = Object.create(proxy);
}

function cascade(prefix, Maker) {
  return lazyObject(prop => Maker(`${prefix}.${prop}`));
}

const SymbolSet = (prefix) => cascade(prefix, Symbol);

const SymbolSetTree = (prefix) => cascade(prefix, SymbolSet);

export const proto = SymbolSetTree('xcl.protocol');

export const pub = SymbolSet('xcl.published');
