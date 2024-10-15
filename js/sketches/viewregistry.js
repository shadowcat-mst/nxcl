export let views = {};

function moveProperty (from, to, prop) {
  let descriptor = Reflect.getOwnPropertyDescriptor(from, prop);
  Reflect.defineProperty(to, prop, descriptor);
  Reflect.deleteProperty(from, prop);
}

function fettlePrototype (proto) {
  let protoProto = Reflect.getPrototypeOf(proto);
  let innerProto = Object.create(null);
  for (let prop of Reflect.ownKeys(proto)) {
    if (prop == 'constructor') continue;
    moveProperty(proto, innerProto, prop);
  }
  Reflect.setPrototypeOf(innerProto, protoProto);
  Reflect.setPrototypeOf(proto, innerProto);
  return innerProto;
}

function addViewTo (viewset, viewClass) {
  let viewName = viewClass.name;
  if (!viewName) throw("https://trout.me.uk/data.jpg");
  let innerProto = fettlePrototype(viewClass.prototype);
  if (viewName in viewset) {
    let oldViewClass = viewset[viewName];
    Reflect.setPrototypeOf(oldViewClass.prototype, innerProto);
  }
  viewset[viewName] = viewClass;
}

export function registry (meta) {
  let urlObj = new URL(meta.url);
  // initial greedy .* ensures last /views/ part in URL just in case
  let m = urlObj.pathname.match(/.*\/views\/(.*?)\.js/);
  if (!m) throw "https://trout.me.uk/bunny.jpg";
  let parts = m[1].split('/');
  let viewset = views;
  for (let part of parts) viewset = viewset[part] ??= {};
  return {
    my: viewset,
    R: (...args) => addViewTo(viewset, ...args),
  };
}
