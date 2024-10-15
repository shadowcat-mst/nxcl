import { registry } from '../../util/exportregistry.js';
import { observable, action, makeObservable } from '../libs.js';
import { tagBuilders, View, ViewWithSubviews, Self } from '../viewcore.js';

let { classes, R } = registry(import.meta);

const { TraceNode, Value, Message } = classes;

export { TraceNode };

let { div, span, ul, li } = tagBuilders;

R(class Value extends View {
  render () {
    return span(
      this.model.toString(),
  ) }
});

R(class Message extends ViewWithSubviews({
  on: Value,
  args: [Value],
}) {

  get call () { return this.model.callDescr() }

  render () {
    return span(
      span(this.call),
      this.on,
      this.args,
    );
  }
});

R(class TraceNode extends ViewWithSubviews({
  value: Value,
  message: Message,
  children: [Self],
}) {

  constructor (args) {
    super(args);
    makeObservable(this, {
      isExpanded: observable,
      toggleExpanded: action.bound,
    });
  }

  isExpanded = true;

  toggleExpanded = () => { this.isExpanded = !this.isExpanded }

  get hasChildren () { return !!this.model.children.length }

  render () {
    return ul(
      li(
        span('ENTER'),
        this.message,
        this.hasChildren && span.toggle(
          { onclick: this.toggleExpanded },
          (this.isExpanded ? '[-]' : '[+]'),
        )
      ),
      this.hasChildren && this.isExpanded
        ? li(this.children)
        : [],
      li(span('LEAVE'), this.value),
    );
  }
});
