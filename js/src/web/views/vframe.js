import { getRegistry } from '../../util/moduleregistry.js';
import { mobx } from '../libs.js';
import { tagBuilders, View } from '../viewcore.js';
import { Reactive } from '../reactive.js';

let { classes, R } = getRegistry(import.meta);

export const { VFrame } = classes;

let { div } = tagBuilders;

R(class VFrame extends Reactive(View, {
  content: null,
  attrs: {
    builder () { return {} },
    filter (newValue) {
      return mobx.observable({ style: {}, ...newValue });
    }
  },
}) {

  get styles () { return this.attrs.style }

  render () {
    return div.vframe(this.attrs, this.content);
  }

});
