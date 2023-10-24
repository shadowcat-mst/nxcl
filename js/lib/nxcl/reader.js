
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

const ATOM_TYPES = [
  'number', 'word', 'symbol', 'qstring', 'call', 'list', 'block'
];

const IS_DELIMITED = Object.from_entries(
  [ 'call', 'list', 'block' ].map(v => [ v, true ])
)

const SEQ_SEP = {
  list: 'comma',
  call: 'semicolon',
  block: 'semicolon',
};

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

  extractToken () {
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

  extractAtom () {
    if (IS_DELIMITED[this.peekType()]) {
      return this.extractDelimited();
    }
    return this.extractToken();
  }

  extractMaybeCompound () {
    let found = this.extractSequenceOf(ATOM_TYPES);
    if (!found.length) {
      throw "WHAT";
    }
    if (found.length == 1) {
      return found[0];
    }
    return {
      type: 'compound',
      value: found,
      start: found.at(0).start,
      end: found.at(-1).end,
    };
  }

  extractSequenceOf (allowedTypes) {
    let isAllowed = Object.from_entries(allowedTypes.map(t => [t, t]));
    let found = [];
    let nextType;
    while (nextType = this.peekType()) {
      if (!nextType in allowedTypes) {
        break;
      }
      found.push(this.extractAtom());
    }
    return found;
  }

  extractDelimited () {
    let type = this.peekType();
    let delimiter_start = this.extractToken();
    let { start } = delimiter_start;
    let allowedTypes = [
      ...ATOM_TYPES, 'ws', SEQ_SEP[type],
    ];
    let found = this.extractSequenceOf(allowedTypes);
    if (this.peekType() != type + '_end') {
      throw "FAIL";
    }
    let delimiter_end = this.extractToken();
    let { end } = delimiter_end;
    let reducer = (type == 'list' ? 'reduceExprList' : 'reduceMaybeExprSeq');
    let value = this[reducer](found);
    return {
      type,
      delimiter_start,
      delimiter_end,
      value,
      start,
      end,
    };
  }
}

export default class Reader {

  parse (source) {
    let st = new ReadState(source);
  }
}
