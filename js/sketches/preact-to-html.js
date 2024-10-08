import render from 'preact-render-to-string/jsx';
import { h, options } from 'preact';

let expandChildren = (children) => children.map(c =>
  (typeof c == 'object' && 'componentFunction' in c)
    ? h(c.componentFunction)
    : (c instanceof Array)
      ? expandChildren(c)
      : c
);

let oldHook = options.vnode;

function vnode (vnode) {
  if (oldHook) oldHook(vnode);
  let { children } = vnode.props;
  if (children) vnode.props.children = expandChildren(
    Array.isArray(children) ? children : [ children ]
  );
}

options.vnode = vnode;

class View {
  constructor (args) {
    Object.assign(this, args);
    this.componentFunction = () => this.render();
  }
}

class TestView extends View {

  subview = new SubView();

  render () { return h('div', {}, this.subview) }
}

class SubView extends View { render () { return h('span', {}, 'foo') } }

let foo = (new TestView()).componentFunction();

console.log(render(foo, null, { jsx: false }));
