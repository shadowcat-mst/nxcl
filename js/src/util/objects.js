export function makeHiddenProp (object, name, value) {
  Object.defineProperty(object, name, {
    enumerable: false,
    writable: true,
    configurable: true,
    value
  })
  return value
}

export function setHiddenProp (object, name, value) {
  if (Object.hasOwn(object, name)) return object[name] = value
  return makeHiddenProp(object, name, value)
}

export function ensureHiddenProp (object, name, builder) {
  if (Object.hasOwn(object, name)) return object[name]
  return makeHiddenProp(object, name, builder())
}

export function Class (name = "AnonClass", superClass = Object) {
  return { [name]: class extends superClass {} }[name]
}

const isBindingClass = Symbol('isBindingClass');

export function BindingClass (name = "BindingClass", superClass = Object) {
  if (superClass[isBindingClass]) return Class(name, superClass)
  const newClass = { [name]: class extends superClass {
    constructor (...args) {
      super(...args)
      bindMethods(this)
    }
    static [isBindingClass] = true
  } }[name]
  return newClass
}

export function bindMethods (object) {
  let targ = object
  while (targ = Object.getPrototypeOf(targ)) {
    if (targ === Object.prototype) break
    for (
      const [ name, descriptor ] of
        Object.entries(Object.getOwnPropertyDescriptors(targ))
    ) {
      if (name === "constructor") continue
      if (Object.hasOwn(object, name)) continue
      let { value } = descriptor
      if (typeof value !== "function") continue
      value = value.bind(object)
      value.curry = (...curried) => (...args) => value(...curried, ...args)
      Object.defineProperty(object, name, { ...descriptor, value })
    }
  }
}

// from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/GeneratorFunction

const GeneratorFunction = function* () {}.constructor

// maybe belongs in a util/predicates.js or something instead; here will
// do for now though

export const isGenerator = (v) => v instanceof GeneratorFunction
