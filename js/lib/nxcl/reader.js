import ReadState0 from './reader/readstate0.js';


export default class Reader {

  parse (source) {
    let st = new ReadState0(source);
    return st.extractAll();
  }
}
