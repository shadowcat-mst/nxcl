import { mobx } from './libs.js';

import {
  makeHiddenProp,
  setHiddenProp,
  ensureHiddenProp,
  Class,
  BindingClass,
  isGenerator,
} from '../util/objects.js';

const propNamesFor = (prefix) => new Proxy({}, {
  get (target, prop, receiver) {
    return prefix + prop
  }
})

const propHandlers = {
  method (object, name, { method }) {
    const wrap = isGenerator(method) ? mobx.flow : mobx.action
    makeHiddenProp(object, name, wrap(method))
  },
  builder (object, name, { builder, filter = v => v, writable }) {
    const { $value, $atom } = propNamesFor(name)
    function ensureAtom () {
      return ensureHiddenProp(this, $atom, () => mobx.createAtom(name))
    }
    const descriptor = {
      get () {
        ensureAtom.call(this).reportObserved()
        return ensureHiddenProp(
          this, $value, () => filter.call(this, builder.call(this))
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
  get (object, name, { get, filter }) {
    const { $reaction, $value, $atom } = propNamesFor(name)
    function ensureReaction () {
      return ensureHiddenProp(this, $reaction, () => new mobx.Reaction(
        () => { this[$atom].reportChanged(); delete this[$value] }
      ))
    }
    this.builder(object, name, {
      filter,
      builder () {
        ensureReaction.call(this).track(() => {
          makeHiddenProp(this, $value, get.call(this))
        })
        return this[$value]
      }
    })
  },
  value (object, name, { value }) {
    this.builder(object, name, {
      builder () { return value },
      writable: true,
    })
  },
  map (object, name, { map: mapper, over }) {
    const { $reaction, $value, $valueMap, $atom } = propNamesFor(name)
    function ensureReaction () {
      return ensureHiddenProp(this, $reaction, () => new mobx.Reaction(
        () => { this[$atom].reportChanged(); delete this[$value] }
      ))
    }
    this.builder(object, name, {
      builder () {
        let over$values
        ensureReaction.call(this).track(() => {
          over$values = over.call(this)
        })
        const oldMap = this[$valueMap] ?? new Map()
        const newMap = new Map(over$values.map(
          (v) => [
            v,
            oldMap.has(v) ? oldMap.get(v) : mapper.call(this, v)
          ]
        ))
        setHiddenProp(this, $valueMap, newMap)
        makeHiddenProp(this, $value, Array.from(newMap.values()))
        return this[$value]
      }
    })
  },
}

const handlerTypes = new Set(Object.keys(propHandlers))

function handlerTypeFor (spec) {
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

function applyConfigTo (config, to) {
  const toProto = to.prototype
  for (const [ k, v ] of expandConfig(config)) {
    propHandlers[handlerTypeFor(v)](toProto, k, v)
  }
  return to
}

export function Reactive(superClass, config) {
  const newClassName = `Reactive${superClass.name}`
  const newClass = BindingClass(newClassName, superClass)
  return applyConfigTo(config, newClass)
}
