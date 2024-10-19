import { observer, createElement, preactOptions, Fragment } from './libs.js';

import { ReactivePropertyDescriptor } from './reactive.js';

import { tagBuilders, vnodeTag } from './fullblade.js';

export { tagBuilders };

{
  // Hook view rendering into preact via preact.options

  let RenderView = observer(({ view }) => {
    view.constructor.reportObserved();
    let r = view.render();
    return Array.isArray(r) ? createElement(Fragment, {}, r) : r;
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

export function subviews (spec) {
  return Object.fromEntries(
    Object.entries(spec).map(([ name, config ]) => {
      let arrayOf = Array.isArray(config);
      let [type] = arrayOf ? config : [config];
      let make = (type == Self) ? null : model => new type({ model });
      return [ name, new ReactivePropertyDescriptor({
        get () {
          let makeV = make ?? (model => new this.constructor({ model }));
          let src = this.model[name];
          return arrayOf ? (src??[]).map(makeV) : makeV(src);
        }
      }) ];
    })
  );
}
