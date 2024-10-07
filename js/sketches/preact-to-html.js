import render from 'preact-render-to-string/jsx';
import { h } from 'preact';

let foo = h('div', {}, h('span', {}, 'foo'));

console.log(render(foo, null, { jsx: false }));
