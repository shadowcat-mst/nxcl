import { Reader } from "../lib/nxcl/reader.js";

let reader = new Reader();

// let type = 'parse';
let type = 'read';

console.log(reader[type]({
  string: "+ x 1"
}));
