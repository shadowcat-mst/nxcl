import { observable, action, makeObservable } from '../libs.js';
import { tagBuilders, View, ViewWithSubviews, Self } from '../view.js';

let { div, span, ul, li } = tagBuilders;

let spanStyle = { style: { outline: "solid 1px", padding: "2px", } };

let liStyle = { style: { padding: '2px' } };

class Value extends View {
  render () {
    return span(
      spanStyle,
      this.model.toString(),
  ) }
}

class Message extends ViewWithSubviews({
  on: Value,
  args: [Value],
}) {

  get call () { return this.model.callDescr() }

  render () {
    return span(
      span(spanStyle, this.call), ' ',
      this.on, ' ',
      this.args.map(a => [ a, ' ' ]),
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
      li(liStyle,
       span(spanStyle, 'ENTER'), ' ',
        span({ onclick: this.toggleExpanded },
          this.message,
          this.hasChildren && (this.isExpanded ? ' [-]' : ' [+]'),
        )
      ),
      this.hasChildren && this.isExpanded
        ? li(liStyle, this.children)
        : [],
      li(liStyle,
        span(spanStyle, 'LEAVE'), ' ', this.value
      ),
    );
  }
}
