import { preact, preactOptions, mobx } from './libs.js';

import { tagBuilders, vnodeTag } from './fullblade.js';

export { tagBuilders };

{
  // Hook view rendering into preact via preact options

  let RenderView = mobx.observer(({ view }) => {
    view.constructor.reportObserved();
    let r = view.render();
    return Array.isArray(r) ? preact.h(preact.Fragment, {}, r) : r;
  });

  let expandChildren = (children) => children.map(c =>
    View.isView(c)
      ? preact.h(c)
      : Array.isArray(c)
        ? expandChildren(c)
        : c
  );

  let oldHook = preactOptions.vnode;

  function newHook (vnode) {
    vnode[vnodeTag] = true;
    let { props } = vnode;
    if (isView(vnode.type)) {
      props.view = vnode.type;
      vnode.type = RenderView;
    }
    let { children } = props;
    if (children) {
      props.children = expandChildren(
        Array.isArray(children) ? children : [ children ]
      );
    }
    if (oldHook) oldHook(vnode);
  }

  preactOptions.vnode = newHook;
}

export class View {

  static isView (thing) { return thing instanceof this }

  constructor (args) {
    if (args) Object.assign(this, args);
  }

  toString () { return `[object ${this.constructor.name}]` }
}

export const isView = View.isView.bind(View)

export function subviews (spec) {
  return Object.fromEntries(
    Object.entries(spec).map(([ name, config ]) => {
      let arrayOf = Array.isArray(config);
      let [type] = arrayOf ? config : [config];
      function map (model) {
        return new (type ?? this.constructor)({ model })
      }
      function over () { return this.model[name] }
      return [
        name,
        arrayOf
          ? { map, over }
          : { filter: map, builder: over }
      ]
    })
  );
}
