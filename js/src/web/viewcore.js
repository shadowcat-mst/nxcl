import { observer, createElement, preactOptions } from './libs.js';

import { tagBuilders, vnodeTag } from './fullblade.js';

export { tagBuilders };

{
  // Hook view rendering into preact via preact.options

  let RenderView = observer(({ view }) => {
    view.constructor.reportObserved();
    return view.render();
  });

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
