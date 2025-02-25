import { mobx } from './libs.js';

import {
  makeHiddenProp,
  setHiddenProp,
  ensureHiddenProp,
  Class,
  BindingClass,
  isGeneratorFunction,
} from '../util/objects.js';

const propNamesFor = (prefix) => new Proxy({}, {
  get (target, prop, receiver) {
    return prefix + prop
  }
})

function makeActionMethod (method) {
  const wrap = isGeneratorFunction(method) ? mobx.flow : mobx.action
  return wrap(method)
}

const propHandlers = {
  method (object, name, { method }) {
    if (!method) throw `No method passed for ${name}`
    makeHiddenProp(object, name, makeActionMethod(method))
  },
  builder (object, name, { builder, filter, writable }) {
    filter ??= v => v
    const { $reaction, $value, $atom } = propNamesFor(name)
    function ensureAtom () {
      return ensureHiddenProp(this, $atom, () => mobx.createAtom(name))
    }
    function ensureReaction () {
      return ensureHiddenProp(this, $reaction, () => new mobx.Reaction(
        `${object.name}.${name}`,
        () => { this[$atom].reportChanged(); delete this[$value] }
      ))
    }
    function buildValue () {
      if (!builder) return undefined
      let value
      ensureReaction.call(this).track(() => {
        value = builder.call(this)
      })
      return value
    }
    const descriptor = {
      get () {
        ensureAtom.call(this).reportObserved()
        return ensureHiddenProp(
          this, $value, () => filter.call(this, buildValue.call(this))
        )
      },
      ...(writable && {
        set (v) {
          ensureAtom.call(this).reportChanged()
          return setHiddenProp(this, $value, filter.call(this, v))
        },
      }),
    }
    Object.defineProperty(object, name, descriptor)
  },
  getset (object, name, { get: builder, set: filter }) {
    const writable = !!filter
    this.builder(object, name, { builder, filter, writable })
  },
  value (object, name, { value }) {
    this.builder(object, name, {
      builder () { return value },
      writable: true,
    })
  },
  map (object, name, { map, over }) {
    if (!(map instanceof Function)) throw `No map function passed for ${name}`
    if (!(over instanceof Function)) throw `No over function passed for ${name}`
    const { $valueMap } = propNamesFor(name)
    this.builder(object, name, {
      builder () {
        // treat null over$values as [] because we've already been told
        // this is an array based prop so that's almost certainly DWIM
        // (we .slice() to ensure we depend on all members track() wise)
        return (over.call(this) ?? []).slice()
      },
      filter (over$values) {
        const oldMap = this[$valueMap] ?? new Map()
        const newMap = new Map(over$values.map(
          (v) => [
            v,
            oldMap.has(v) ? oldMap.get(v) : map.call(this, v)
          ]
        ))
        setHiddenProp(this, $valueMap, newMap)
        return Array.from(newMap.values())
      }
    })
  },
}

const handlerTypes = new Set(Object.keys(propHandlers))

function handlerTypeFor (spec) {
  if (Object.hasOwn(spec, 'get')) return 'getset'
  const keys = Object.keys(spec)
  const [ type, tooMany ] = handlerTypes.intersection(new Set(keys))
  if (tooMany) throw `Ambiguity! ${keys.join(", ")}`
  if (!type)   throw `No handler found! ${keys.join(", ")}`
  return type
}

function expandConfig (config) {
  return Object.entries(
    Object.getOwnPropertyDescriptors(config)
  ).map(([ k, v ]) => {
    if (v.value !== null && typeof v.value === "object") v = v.value
    else if (typeof v.value === "function") v = { method: v.value }
    return [ k, v ]
  })
}

const reactiveExtras = {
  $_method (method) {
    return makeActionMethod(method).bind(this)
  },
  $_run (method, ...args) {
    return this.$_method(method)(...args)
  },
  $_bind (name, bindTo, boundName) {
    Object.defineProperty(this, name, {
      get () { return bindTo[boundName] },
      set (v) { bindTo[boundName] = v },
    })
    return this
  },
}

export function Reactive(superClass, config) {
  const newClassName = `Reactive${superClass.name}`
  const newClass = BindingClass(newClassName, superClass)
  const newProto = newClass.prototype
  for (const [ k, v ] of Object.entries(reactiveExtras)) {
    makeHiddenProp(newProto, k, v)
  }
  for (const [ k, v ] of expandConfig(config)) {
    propHandlers[handlerTypeFor(v)](newProto, k, v)
  }
  return newClass
}
