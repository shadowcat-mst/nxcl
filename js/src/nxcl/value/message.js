import { proto } from "../constants.js";
import { Value, _Message } from "../value.js";

let { CALL } = proto.core;

export class Message extends Value {

  *[CALL] (cx, args) {
    if (!Object.hasOwn(this, 'withArgs')) {
      let withArgs = [];
      for (let argp of args) {
        let arg = yield* cx.eval(argp);
        withArgs.push(arg);
      }
      return new this.constructor({ ...this, withArgs });
    }
    let on, sendArgs;
    if (on = this.on) {
      sendArgs = [ ...this.withArgs, ...args ];
    } else {
      let [ first, ...rest ] = args;
      on = yield* cx.eval(first);
      sendArgs = [ ...this.withArgs, ...rest ];
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
  }

  valueToExternalString () {
    function splatArgs (args) {
      if (!args.length) return '()';
      return '( ' + args.map(x => x.toExternalString()).join(', ') + ' )';
    }
    return [
      ':call ' + this.callDescr(),
      ...this.on ? [ ':on ' + this.on.toExternalString() ] : [],
      ...Object.hasOwn(this, 'withArgs')
        ? [ ':with-args ' + splatArgs(this.withArgs) ]
        : [],
    ].join(', ');
  }
}

_Message.$value = Message;
