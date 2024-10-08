import render from 'preact-render-to-string/jsx';
import { h, options } from 'preact';

let RenderView = ({ view }) => view.render();

let expandChildren = (children) => children.map(c =>
  (c instanceof View)
    ? h(c)
    : Array.isArray(c)
      ? expandChildren(c)
      : c
);

let oldHook = options.vnode;

function newHook (vnode) {
  if (vnode.type instanceof View) {
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

class View {
  constructor (args) {
    Object.assign(this, args);
  }

  toString () { return `[object ${this.constructor.name}]` }
}

class TestView extends View {

  subview = new SubView();

  render () { return h('div', {}, this.subview) }
}

class SubView extends View { render () { return h('span', {}, 'foo') } }

let foo = h(new TestView());

let shallow = false;

console.log(render(foo, null, { jsx: false, shallow }));
