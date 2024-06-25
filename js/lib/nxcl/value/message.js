import { proto } from "../constants.js";
import { Value, _Message } from "../value.js";

export class Message extends Value {

  *[proto.core.CALL] (cx, args) {
    if (!Object.hasOwn(this, 'withArgs')) {
      let withArgs = yield* cx.eval(args);
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

  valueToExternalString () {
    function splatArgs (args) {
      if (!args.length) return '()';
      return '( ' + args.map(x => x.toExternalString()).join(', ') + ' )';
    }
    return [
      ':call ' + this.call.toString(),
      ...(this.on ? ':on ' + [ this.on.toExternalString() ] : []),
      ...Object.hasOwn(this, 'withArgs')
        ? [ ':with-args ' + splatArgs(this.withArgs) ]
        : [],
    ].join(', ');
  }
}

_Message.$value = Message;
