#!/usr/bin/env -S bun run
import { Reader } from "../lib/nxcl/reader.js";

let reader = new Reader();

// let type = 'parse';
let type = 'read';

console.log(reader[type]({
  string: (Bun.argv[2] ?? "+ x 1"),
}).toExternalString());
