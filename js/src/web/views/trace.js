import { registry } from '../viewregistry.js';
import { observable, action, makeObservable } from '../libs.js';
import { tagBuilders, View, ViewWithSubviews, Self } from '../viewcore.js';

let { my, R } = registry(import.meta);

let { div, span, ul, li } = tagBuilders;

R(class Value extends View {
  render () {
    return span(
      this.model.toString(),
  ) }
});

R(class Message extends ViewWithSubviews({
  on: my.Value,
  args: [my.Value],
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
  value: my.Value,
  message: my.Message,
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
