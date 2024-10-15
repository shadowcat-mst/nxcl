import { lazyObject } from "../util/lazy.js";

function cascade(prefix, Maker) {
  return lazyObject(prop => Maker(`${prefix}.${prop}`));
}

const SymbolSet = (prefix) => cascade(prefix, Symbol);

const SymbolSetTree = (prefix) => cascade(prefix, SymbolSet);

export const proto = SymbolSetTree('xcl.protocol');

export const pub = SymbolSet('xcl.published');
