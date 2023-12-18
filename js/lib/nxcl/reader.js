import LexState from './reader/lexstate.js';

export default class Reader {

  lex (source) {
    let st = new LexState(source);
    return st.extractAll();
  }
}
