let typeMap = {
  word: Name, symbol: Name,
  string: String, digits: Digits,
  list: List, block: Block, call: Call, eseq: ESeq,
};

class ExpandState {

  constructor (nodes) {
    this.nodes = nodes;
  }

  nextNode () { return this.nodes.shift() }

  subStateFor (node) {
    return new this.contructor(node.contents);
  }

  extractAll () {
    let res = [];
    while (this.nodes) {
      res.push(this.extractOne());
    }
    return res;
  }

  extractOne () {
    let node = { ...this.nextNode() };
    let Type = typeMap[node.type];
    delete node.type;
    let new = { };
    if (node.contents) {
      new.contents = node.contents.map(
        n => this.subStateFor(n).extractAll()
      );
      delete node.contents;
    } else {
      new.value = node.value;
      delete node.value;
    }
    return new Type({ ...new, readerMeta: node });
  }
}
