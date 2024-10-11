class Node {

  // has: message, value, parent, children

  children = [];

  constructor (args) {
    Object.assign(this, args);
  }

  addChildFor (message) {
    let child = new this.constructor({ message, parent: this });
    this.children.push(child);
    return child;
  }

  completeNode (value) {
    this.value = value;
    return this.parent;
  }
}

export class TraceBuilder {

  addChildFor (message) {
    // deliberately set no parent since the root object should only
    // .completeNode() at the end of the traced evaluation

    return this.rootNode = new Node({ message });
  }

  get handler () {
    let current = this;
    return (type, payload) => {
      if (type == 'enter') {
        current = current.addChildFor(payload);
      } else if (type == 'leave') {
        current = current.completeNode(payload);
      }
    };
  }

  get evalOpts () {
    return { eventHandlers: { trace: this.handler } };
  }

  buildView (viewClass) {
    return new viewClass({ model: this.rootNode });
  }
}
