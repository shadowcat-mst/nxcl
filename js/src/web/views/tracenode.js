import { observable, action, makeObservable } from 'mobx';
import { tagBuilders, View, ViewWithSubviews, Self } from '../view.js';

let { div, span, table, tbody, tr, td, ul, li } = tagBuilders;

class Value extends View {
  render () { return span(this.model.toString()) }
}

class Message extends ViewWithSubviews({
  on: Value,
  args: [Value],
}) {

  get call () { return this.model.callDescr() }

  render () {
    return table(
      { border: 1 },
      tbody(tr(
        td(this.call),
        td(this.on),
        this.args.map(v => td(v)),
      ))
    );
  }
}

export class TraceNode extends ViewWithSubviews({
  value: Value,
  message: Message,
  children: [Self],
}) {

  constructor (args) {
    super(args);
    makeObservable({
      isExpanded: observable,
      toggleExpanded: action.bound,
    });
  }

  isExpanded = true;

  toggleExpanded () { this.isExpanded = !this.isExpanded }

  get hasChildren () { return !!this.model.children.length }

  render () {
    return ul(
      li('ENTER ',
        span({ onclick: this.toggleExpanded },
          this.message,
          this.hasChildren && (this.isExpanded ? '[-]' : '[+]'),
        )
      ),
      this.hasChildren && this.isExpanded
        ? li(this.children)
        : [],
      li('LEAVE ', this.value),
    );
  }
}
