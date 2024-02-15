import { LexState } from './reader/lexstate.js';
import { ParseState } from './reader/parsestate.js';
import { ExpandState } from './reader/expandstate.js';

export class Reader {

  lex (source) {
    let st = new LexState(source);
    return st.extractAll();
  }

  parse (source) {
    let st = new ParseState(this.lex(source));
    return st.extractExprSeq();
  }

  read (source) {
  }
}
