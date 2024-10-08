import render from 'preact-render-to-string/jsx';
import { h, options } from 'preact';

// Hook view rendering into preact via preact.options

let RenderView = ({ view }) => view.render();

let expandChildren = (children) => children.map(c =>
  View.isView(c)
    ? h(c)
    : Array.isArray(c)
      ? expandChildren(c)
      : c
);

let oldHook = options.vnode;

function newHook (vnode) {
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

options.vnode = newHook;

// hyperaxe style trickery (lazyObject borrowed from nxcl/constants.js)

function lazyObject(builder) {
  let obj, proxy = new Proxy({}, {
    get (target, prop, receiver) {
      return obj[prop] = builder(prop);
    }
  });
  return obj = Object.create(proxy);
}

let tagBuilders = lazyObject(prop => (...args) => h(prop, ...args));

// Define some stuff that uses the above

class View {

  static isView (thing) { return thing instanceof this }

  constructor (args) {
    Object.assign(this, args);
  }

  toString () { return `[object ${this.constructor.name}]` }
}

let { div, span } = tagBuilders;

class TestView extends View {

  subview = new SubView();

  render () { return div({}, this.subview) }
}

class SubView extends View { render () { return span({}, 'foo') } }

let foo = h(new TestView());

let shallow = false;

console.log(render(foo, null, { jsx: false, shallow }));
