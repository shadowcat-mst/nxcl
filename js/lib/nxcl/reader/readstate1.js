function makeTypeTest (typeList) {
  let types = Object.from_entries(typeList.map(v => [ v, true ]);
  return x => types[x.type];
}

const IS_MATERIAL = makeTypeTest(
  [ 'digits', 'word', 'symbol', 'qstring', 'call', 'list', 'block' ]
);

const IS_INTERSTITIAL = makeTypeTest(
  [ 'ws', 'comment', 'comma', 'semicolon' ]
);

const IS_COMMA = t => t.type == 'comma';

const IS_SEMICOLON = t => t.type == 'semicolon';

class ReadState1 {

  constructor (tokens) {
    this.tokens = tokens;
  }

  peekNode () { this.tokens[0] }

  peekType () { this.peekNext().type }

  nextNode () { this.tokens.shift() }

  extractWhile (cond) {
    let res = [];
    while (cond(this.peekNode())) {
      res.push(this.extractOne());
    }
    return res;
  }

  maybeWrap (type, contents) {
    if (contents.length == 1) return contents[0];
    return {
      type,
      start: contents.at(0).start,
      end: contents.at(-1).end,
      contents,
      source: contents.at(0).source,
    };
  }

  extractMaybeCompound () {
    let found = this.extractWhile(IS_MATERIAL);
    return this.maybeWrap('compound', found);
  }

  extractList () {
    let list = this.nextNode();
    return {
      ...list,
      ...(new this.constructor(list.contents)).extractListBody(),
    };
  }

  extractListBody () {
    let is_before = this.extractWhile(IS_INTERSTITIAL), is_after;
    if (is_before.some(IS_SEMICOLON)) throw `Semicolon invalid here`;
    let cur = [], res = [];
    while (this.tokens) {
      let next = this.extractMaybeCompound();
      let is_after = this.extractWhile(IS_INTERSTITIAL);
      if (is_after.some(IS_SEMICOLON)) throw `Semicolon invalid here`;
      cur.push({ ...next, is_before, is_after });
      if (is_after.some(IS_COMMA)) {
        res.push(cur);
        cur = [];
      }
      is_before = is_after;
    }
    if (cur) res.push(cur);
    if (!res) return { contents: [], is_inside: is_before };
    return { contents: res.map(r => this.maybeWrap('call', r)) };
  }
}
