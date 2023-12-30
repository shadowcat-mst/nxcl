import {
  Name, String, Digits, List, Block, Call, ESeq
} from "../valuetypes.js";

let typeMap = {
  word: Name, symbol: Name,
  string: String, digits: Digits,
  list: List, block: Block, call: Call, eseq: ESeq,
};

export class ExpandState {

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
    let next = { };
    if (node.contents) {
      next.contents = node.contents.map(
        n => this.subStateFor(n).extractAll()
      );
      delete node.contents;
    } else {
      next.value = node.value;
      delete node.value;
    }
    return new Type({ ...next, readerMeta: node });
  }
}
