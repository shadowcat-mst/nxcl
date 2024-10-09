import { proto } from "../constants.js";
import { Value, _Message } from "../value.js";

let { CALL } = proto.core;

export class Message extends Value {

  *[CALL] (cx, args) {
    if (!Object.hasOwn(this, 'args')) {
      let newArgs = [];
      for (let argp of args) {
        let arg = yield* cx.eval(argp);
        newArgs.push(arg);
      }
      return new this.constructor({ ...this, args: newArgs });
    }
    let on, sendArgs;
    if (on = this.on) {
      sendArgs = [ ...this.args, ...args ];
    } else {
      let [ first, ...rest ] = args;
      on = yield* cx.eval(first);
      sendArgs = [ ...this.args, ...rest ];
    }
    return yield* cx.send(on, this.call, sendArgs);
  }

  callDescr() {
    let callDescr = (typeof this.call == 'symbol'
      ? this.call
            .description
            .replace('xcl.protocol.', '')
            .replace(/\./, '::')
      : this.call.toString()
    );
    return callDescr;
  }

  valueToExternalString () {
    function splatArgs (args) {
      if (!args.length) return '()';
      return '( ' + args.map(x => x.toExternalString()).join(', ') + ' )';
    }
    return [
      ':call ' + this.callDescr(),
      ...this.on ? [ ':on ' + this.on.toExternalString() ] : [],
      ...Object.hasOwn(this, 'args')
        ? [ ':args ' + splatArgs(this.args) ]
        : [],
    ].join(', ');
  }
}

_Message.$value = Message;
