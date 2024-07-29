'use strict';

// TOK_MATCH regexp assembly needs \\ and TOK_START assembly won't mind a dupe

const SYMBOL_CHARS = '.!$%&:<=>@\\\\^|~?*/+-';

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
  Object.entries(TOK_TYPES).flatMap(
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
  ...Object.fromEntries(Object.entries(TOK_TYPES_CONTD).map(
    ([ k, v ]) => [ k, new RegExp(`^([${v}]+)`) ]
  )),
  qstring: /'(.*?(?<=[^\\])(?:\\\\)*)'/s,
};

const IS_OPEN = Object.fromEntries(
  [ 'call', 'list', 'block' ]
    .map(v => [ v, v ])
)

const IS_CLOSE = Object.fromEntries(
  [ 'call', 'list', 'block' ]
    .map(v => [ `${v}_end`, v ])
)

export class LexState {

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
    let { pos, line, linepos, string, source } = this;
    let start = { pos, line, linepos };
    let type = this.peekType();
    if (!type) {
      throw `Unexpected ${this.peekChar()||'end of input'}`;
    }
    let value, length;
console.log('Matching:', type, 'with:', TOK_MATCH[type]);
    string = string.replace(
      TOK_MATCH[type], (m, t) => { value = t; length = m.length; return '' }
    );
    pos += length;
    let m;
    if (m = value.match(/\n([^\n]*)$/)) {
      line += value.match(/\n/g).length;
      linepos = m[0].length;
    } else {
      linepos += length;
    }
    let end = { pos, line, linepos };
    Object.assign(this, { ...end, string });
    return {
      type,
      start,
      end,
      value,
      source,
    };
  }

  extractOne () {
    let nextType = this.peekType();
    if (IS_OPEN[nextType]) {
      return this.extractDelimited();
    }
    if (nextType == 'qstring') {
      return this.extractQString();
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
      // later we should pass down the stack of opens currently in play so
      // we can report the start of what we think we just saw the end of
      throw `Expected end of ${type}, saw end of ${closeType} instead`;
    }
    let delimiter_end = this.extractToken();
    let { end } = delimiter_end;
    let { source } = this;
    return {
      type,
      delimiter_start,
      delimiter_end,
      start,
      end,
      contents,
      source,
    };
  }

  extractQString () {
    let tok = this.extractToken();
    let delimiter_start, delimiter_end, contents;
    {
      let type = 'quote';
      let value = "'";
      let c_start, c_end;
      {
        let { pos, line, linepos } = tok.start;
        pos++; linepos++;
        delimiter_start = {
          type, value,
          start: tok.start,
          end: c_start = { pos, line, linepos },
        };
      }
      {
        let { pos, line, linepos } = tok.end;
        pos--; linepos--;
        delimiter_end = {
          type, value,
          start: c_end = { pos, line, linepos },
          end: tok.end,
        };
      }
    /*  contents = [ {
        type: 'qchars',
        start: c_start,
        end: c_end,
        value: tok.value,
      } ]; */
    }
    let { start, end, type, value } = tok;
    let { source } = this;
    return {
      type,
      delimiter_start,
      delimiter_end,
      start,
      end,
      value,
      source,
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
