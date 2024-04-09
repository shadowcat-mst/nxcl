#!/usr/bin/env -S bun run
import { Reader } from "../lib/nxcl/reader.js";

console.log((new Reader())[Bun.argv[3] ?? 'read']({
  string: (Bun.argv[2] ?? "+ x 1"),
}));
