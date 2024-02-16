function makeTypeTest (typeList) {
  let types = Object.fromEntries(typeList.map(v => [ v, true ]));
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

const EXTRACTOR_FOR = {
  list: 'extractList',
  block: 'extractBlock',
  call: 'extractCall',
};

export class ParseState {

  constructor (tokens) {
    this.tokens = tokens;
  }

  peekNode () { return this.tokens[0] }

  peekType () { return this.peekNode().type }

  nextNode () { return this.tokens.shift() }

  subStateFor (node) {
    return new this.contructor(node.contents);
  }

  extractOne () {
    let extractor;
    if (extractor = EXTRACTOR_FOR[this.peekType()]) {
      return this[extractor]();
    }
    return this.nextNode();
  }

  extractWhile (cond) {
    let res = [];
    while (this.tokens.length && cond(this.peekNode())) {
      res.push(this.extractOne());
    }
    return res;
  }

  maybeWrap (type, contents) {
    if (contents.length == 1) return contents[0];
    return this.wrap(type, contents);
  }

  wrap (type, contents) {
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
      contents: this.subStateFor(list)
                    .extractListBody()
                    .map(e => this.maybeWrap('call', e)),
    };
  }

  extractBlock () {
    let block = this.nextNode();
    return {
      ...block,
      contents: this.subStateFor(block)
                    .extractRawExprSeq()
                    .map(e => this.maybeWrap('call', e)),
    };
  }

  extractCall () {
    let call = this.nextNode();
    let raw = this.subStateFor(call).extractRawExprSeq();
    let contents = (
      (raw.length == 1)
        ? raw[0]
        : [ this.wrap('eseq', raw.map(e => this.maybeWrap('call', e))) ]
    );
    return {
      ...call,
      contents,
    };
  }

  extractListBody () {
    return this.extractSeparated(
      is => { if (is.some(IS_SEMICOLON)) throw `Semicolon invalid here` },
      is => is.some(IS_COMMA),
    );
  }

  extractRawExprSeq () {
    return this.extractSeparated(
      is => { if (is.some(IS_COMMA)) throw `Comma invalid here` },
      (is, last) => {
        if (is.some(IS_SEMICOLON)) return true;
        if (last.type != 'block') return false;
        return is.some(x => (x.type == 'ws' && x.value.includes("\n")));
      },
    );
  }

  extractExprSeq () {
    return this.wrap(
      'eseq', this.extractRawExprSeq().map(e => this.maybeWrap('call', e))
    );
  }

  extractSeparated (checkIS, hasSeparator) {
    let is_before = this.extractWhile(IS_INTERSTITIAL), is_after;
    checkIS(is_before);
    let cur = [], res = [];
    while (this.tokens.length) {
      let next = this.extractMaybeCompound();
      let is_after = this.extractWhile(IS_INTERSTITIAL);
      checkIS(is_after);
      cur.push({ ...next, is_before, is_after });
      let last = next.type == 'compound' ? next.contents[0] : next;
      if (hasSeparator(is_after, last)) {
        res.push(cur);
        cur = [];
      }
      is_before = is_after;
    }
    if (cur) res.push(cur);

    // Need a replacement for this that I don't hate.
    //
    // if (!res) return { contents: [], is_inside: is_before };

    return res;
  }
}
