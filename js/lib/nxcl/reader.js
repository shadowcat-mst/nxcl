'use strict';

const SYMBOL_CHARS = '.!$%&:<=>@\\^|~?*/+-';

const DIGITS = '0123456789';

const ALPHABET_LC = 'abcdefghijklmnopqrstuvwxyz';

const ALPHABET_UC = ALPHABET_LC.toUpperCase();

const WORD_START = ALPHABET_LC + ALPHABET_UC + '_';

const WORD_CHARS = WORD_START + DIGITS + '-';

const TOK_TYPES = {
  ws: " \t\n",
  symbol: SYMBOL_CHARS,
  word: WORD_START,
  digits: DIGITS,
  qstring: "'",
  comma: ',',
  semicolon: ';',
  call: '[',
  call_end: ']',
  list: '(',
  list_end: ')',
  block: '{',
  block_end: '}',
};

const TOK_START = Object.fromEntries(
  TOK_TYPES.entries().flatMap(
    ([ k, v ]) => v.split('').map(v => [ v, k ])
  )
);

const TOK_TYPES_CONTD = {
  ...TOK_TYPES,
  word: WORD_CHARS,
  call: "\\[",
  call_end: "\\]",
  list: "\\(",
  list_end: "\\)",
  block: "\\{",
  block_end: "\\}",
};

const TOK_MATCH = {
  ...TOK_TYPES_CONTD.entries().map(
    ([ k, v ]) => [ k, new Regexp(`^([${v}])`) ]
  ),
  qstring: /'(.*?(?<=[^\\])(?:\\\\)*)'/s,
};

const IS_OPEN = Object.from_entries(
  [ 'call', 'list', 'block' ]
    .map(v => [ v, v ])
)

const IS_CLOSE = Object.from_entries(
  [ 'call', 'list', 'block' ]
    .map(v => [ `${v}_end`, v ])
)

class ReadState {

  pos = 0;
  line = 1;
  linepos = 0;

  constructor (source) {
    this.string = source.string;
    this.source = source;
  }

  peekChar () {
    return this.string.charAt(0);
  }

  peekType () {
    return TOK_START[this.peekChar()];
  }

  currentPosition () {
    return { pos: this.pos, line: this.line, linepos: this.linepos };
  }

  extractToken () {
    let { pos. line, linepos, string, source } = this;
    let start = { pos. line, linepos };
    let type = this.peekType();
    if (!type) {
      throw `Unexpected ${this.peekChar()||'end of input'}`;
    }
    let value, length;
    string = string.replace(
      TOK_MATCH[type], (m, t) => { value = t; length = m.length; return '' }
    );
    pos += length;
    if (let m = value.match(/\n([^\n]*)$/)) {
      line += value.match(/\n/g).length;
      linepos = m[0].length;
    } else {
      linepos += length;
    }
    let end = { pos, line, linepos };
    Object.assign(this, { ...end, string });
    return { type, value, source, start, end };
  }

  extractOne () {
    if (IS_OPEN[this.peekType()]) {
      return this.extractDelimited();
    }
    return this.extractToken();
  }

  extractDelimited () {
    let type = this.peekType();
    let delimiter_start = this.extractToken();
    let { start } = delimiter_start;
    let contents = [];
    let closeType;
    while (!(closeType = IS_CLOSE[this.peekType()])) {
      contents.push(this.extractOne());
    }
    if (closeType != type) {
      throw `Expected end of ${type}, saw end of ${closeType} instead`;
    }
    let delimiter_end = this.extractToken();
    let { end } = delimiter_end;
    return {
      type,
      delimiter_start,
      delimiter_end,
      contents,
      start,
      end,
    };
  }

  extractAll () {
    let ret = [];
    while (this.string) {
      ret.push(this.extractOne());
    }
    return ret;
  }
}

export default class Reader {

  parse (source) {
    let st = new ReadState(source);
  }
}
