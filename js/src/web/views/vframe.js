import { getRegistry } from '../../util/moduleregistry.js';
import { mobx } from '../libs.js';
import { View } from '../viewcore.js';
import { Reactive } from '../reactive.js';

const { classes: { VFrame }, R } = getRegistry(import.meta);

export { VFrame }

R(class VFrame extends Reactive(View, {
  content: null,
  set attrs (newValue) {
    return mobx.observable({ style: {}, ...newValue });
  },
}) {

  get styles () { return this.attrs.style }

  render () {
    const { div } = this.h
    return div.vframe(this.attrs, this.content);
  }

});
