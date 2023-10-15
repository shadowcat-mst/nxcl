
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
  number: DIGITS,
  qstring: "'",
  comma: ",",
  call: "[",
  list: '(',
  block: '{',
};

const TOK_START = Object.fromEntries(
  TOK_TYPES.entries().flatMap(
    ([ k, v ]) => v.split('').map(v => [ v, k ])
  )
);

const TOK_TYPES_CONTD = {
  ...TOK_TYPES,
  word: WORD_CHARS,
};

const TOK_MATCH = {
  ...TOK_TYPES_CONTD.entries().map(
    ([ k, v ]) => [ k, new Regexp(`^([${v}])`) ]
  ),
  qstring: /'(.*?(?<=[^\\])(?:\\\\)*)'/s,
};

class ReadState {

  pos = 0;
  line = 1;
  linepos = 0;

  constructor (string, source) {
    this.string = string;
    this.source = source;
  }

  peekType () {
    return TOK_START[this.string.charAt(0)];
  }

  extractNext () {
    let { pos. line, linepos, string, source } = this;
    let start = { pos. line, linepos };
    let type = this.peekType();
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
    return { type, value, start, end };
  }
}
