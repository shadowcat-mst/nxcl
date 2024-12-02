import { mobx } from '../web/libs.js';

class Predeclaration {
  constructor () {
    throw `Attempt to construct predeclared class ${this.constructor.name}`;
  }
}

class ModuleRegistry {

  classes = { __proto__: new Proxy({}, {
    get: (target, prop, receiver) => this.predeclareClass(prop)
  })};

  R = this.register.bind(this);

  register (userClass) {
    let name = userClass.name;
    if (!name) throw "anonymous classes are verboten";
    let myClass = this.predeclareClass(name);
    Reflect.setPrototypeOf(myClass, userClass);
    Reflect.setPrototypeOf(myClass.prototype, userClass.prototype);
    myClass.reportChanged();
    return myClass;
  }

  predeclareClass (name) {
    if (Reflect.has(this.classes, name)) return this.classes[name];
    let classAtom = mobx.createAtom(name);
    let newClass = {
      [name]: class extends Predeclaration {
        static reportObserved () { classAtom.reportObserved() }
        static reportChanged () { classAtom.reportChanged() }
      }
    }[name];
    return this.classes[name] = newClass;
  }
}

let registries = {};

function nameForURL (url) {
  let urlObj = new URL(url);
  let m = urlObj.pathname.match(/.*\/(views\/.*?)\.js/);
  if (!m) throw "https://trout.me.uk/bunny.jpg";
  return m[1];
}

export function getRegistry (meta) {
  let registryName = nameForURL(meta.url);
  return registries[registryName] ??= new ModuleRegistry();
}
