import { lazyObject, lazyFunctionObject } from '../nxcl/util/lazy.js';
import { observer, createElement, preactOptions } from './libs.js';

// Going to have to think about how we deal with this wrt hot reload

let vnodeTag = Symbol('vnodeTag');

{
  // Hook view rendering into preact via preact.options

  let RenderView = observer(({ view }) => view.render());

  let expandChildren = (children) => children.map(c =>
    View.isView(c)
      ? createElement(c)
      : Array.isArray(c)
        ? expandChildren(c)
        : c
  );

  let oldHook = preactOptions.vnode;

  function newHook (vnode) {
    vnode[vnodeTag] = true;
    if (View.isView(vnode.type)) {
      vnode.props.view = vnode.type;
      vnode.type = RenderView;
    }
    let { children } = vnode.props;
    if (children) {
      vnode.props.children = expandChildren(
        Array.isArray(children) ? children : [ children ]
      );
    }
    if (oldHook) oldHook(vnode);
  }

  preactOptions.vnode = newHook;
}

function isPlainObject (thing) {
  return (
    typeof thing == 'object'
    && Object.getPrototypeOf(thing) == Object.prototype
    && !thing[vnodeTag]
  );
}

// a lazyObject based hyperaxe

export { createElement as 'h' };

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
    return createElement(tagName, props, args);
  }
  return lazyFunctionObject(func,
    propName => makeTagBuilder([ ...classes, kebab(propName) ], tagName)
  );
};

export const tagBuilders = lazyObject(
  propName => makeTagBuilder([], kebab(propName))
);

export const Self = Symbol('Self');

export class View {

  static isView (thing) { return thing instanceof this }

  constructor (args) {
    Object.assign(this, args);
  }

  toString () { return `[object ${this.constructor.name}]` }
}

export function ViewWithSubviews (subviews) {
  let newBase = class ViewWithSubviews extends View {};
  for (let [ name, config ] of Object.entries(subviews)) {
    let arrayOf = Array.isArray(config);
    let [type] = arrayOf ? config : [config];
    let slot = '_' + name;
    let make = (type == Self) ? null : model => new type({ model });
    Object.defineProperty(newBase.prototype, name, {
      get () {
        if (slot in this) return this[slot];
        let makeV = make ?? (model => new this.constructor({ model }));
        let src = this.model[name];
        return this[slot] = arrayOf ? (src??[]).map(makeV) : makeV(src);
      }
    });
  }
  return newBase;
}
