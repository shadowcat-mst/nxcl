import { getRegistry } from '../../util/moduleregistry.js';
import { View, subviews } from '../viewcore.js';
import { Reactive } from '../reactive.js';

const { classes: { TraceNode, Value, Message }, R } = getRegistry(import.meta);

export { TraceNode };

R(class Value extends View {
  render () {
    const { span } = this.tagBuilders
    return span(this.model.toString())
  }
});

R(class Message extends Reactive(View, subviews({
  on: Value,
  args: [Value],
})) {

  get call () { return this.model.callDescr() }

  render () {
    const { span } = this.tagBuilders
    return [
      span(this.call),
      this.on,
      this.args,
    ];
  }
});

R(class TraceNode extends Reactive(View, {
  ...subviews({
    value: Value,
    message: Message,
    children: [],
  }),
  isExpanded: false,
  toggleExpanded () { this.isExpanded = !this.isExpanded },
}) {

  get hasChildren () { return !!this.model.children.length }

  render () {
    const { ul, li, span } = this.tagBuilders
    return ul(
      li(
        span.bright('->'),
        this.message,
        this.hasChildren && span.toggle(
          { onclick: this.toggleExpanded },
          (this.isExpanded ? '[-]' : '[+]'),
        )
      ),
      this.hasChildren && this.isExpanded
        ? li(this.children)
        : [],
      li(span.bright('<-'), this.value),
    );
  }
});
