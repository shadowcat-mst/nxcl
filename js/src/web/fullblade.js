import { preact } from './libs.js';
import { lazyObject, lazyFunctionObject } from '../util/lazy.js';

// a lazyObject based hyperaxe

function isPlainObject (thing) {
  return (
    typeof thing == 'object'
    && Object.getPrototypeOf(thing) == Object.prototype
    && !thing[vnodeTag]
  );
}

// Going to have to think about how we deal with this wrt hot reload

export let vnodeTag = Symbol('vnodeTag');

// 'fooBar' -> 'foo-bar'

let kebab = (name) => 
  name.split(/(?=[A-Z])/)
      .map(x => x.toLowerCase())
      .join('-');

let makeTagBuilder = (classes, tagName) => {
  let func = (...args) => {
    let props = isPlainObject(args[0]) ? { ...args.shift() } : {};
    if (classes.length) {
      props.class = [
        ...classes,
        ...(
          props.class
            ? Array.isArray(props.class) ? props.class : [ props.class ]
            : []),
      ];
    }
    return preact.h(tagName, props, args);
  }
  return lazyFunctionObject(func,
    propName => makeTagBuilder([ ...classes, kebab(propName) ], tagName)
  );
};

export const h = lazyFunctionObject(
  preact.h,
  propName => makeTagBuilder([], kebab(propName))
);
