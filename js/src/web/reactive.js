import { action, computed, flow, createAtom } from './libs.js';

function makeDollarProp (obj, name, value) {
  Object.defineProperty(obj, name, {
    enumerable: false,
    writable: true,
    value
  });
  return value;
}

function ownEntries (obj) {
  return Object.entries(
    Object.getOwnPropertyDescriptors(obj)
  );
}

export class ReactivePropertyDescriptor {
  constructor (args) { Object.assign(this, args) }
}

// from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/GeneratorFunction

const GeneratorFunction = function* () {}.constructor;

export function Reactive (superClass, tprops) {
  return new ReactiveClassBuilder({ superClass, tprops }).build();
}

export class ReactiveClassBuilder {

  constructor (args) { Object.assign(this, args) }

  makeValueDescriptorsFor(tname, tdescr) {

    let value = tdescr.value;
    let valueType = typeof value;

    if (valueType == 'object') {
      throw `Can't pass object value for Reactive() arg ${tname}; try set`;
    }

    if (valueType == 'function') {
      return this.makeFunctionDescriptorsFor(tname, value);
    }

    return this.makePlainValueDescriptorsFor(tname, value);
  }

  makeFunctionDescriptorsFor(tname, tvalue) {
    let actionName = tname + '$action';

    let functionName = tname + '$actionFunction';

    // action() and flow() both pass through 'this'

    let actionFn = (
      tvalue instanceof GeneratorFunction
        ? flow(function (...args) { return this[functionName](...args) })
        : action(function (...args) { return this[functionName](...args) })
    );

    return [
      [ functionName, {
        enumerable: false,
        value: tvalue,
      } ],
      [ tname, {
        enumerable: false,
        get () {
          return this[actionName]
            ?? makeDollarProp(this, actionName, actionFn.bind(this))
        },
       } ],
    ];
  }

  makePlainValueDescriptorsFor (tname, tvalue) {

    let atomName = tname + '$atom', valueName = tname + '$value';

    return [[ tname, {
      get () {
        let atom = this[atomName]
          ?? makeDollarProp(this, atomName, createAtom(tname));
        atom.reportObserved();
        return Object.hasOwn(this, valueName)
          ? this[valueName]
          : this[valueName] = tvalue;
      },
      set (newValue) {
        let atom = this[atomName]
          ?? makeDollarProp(this, atomName, createAtom(tname));
            atom.reportChanged();
        return Object.hasOwn(this, valueName)
          ? this[valueName] = newValue
          : makeDollarProp(this, valueName, newValue);
      },
    } ]];
  }

  makeSetterDescriptorsFor (tname, tdescr) {
    let atomName = tname + '$atom', valueName = tname + '$value';
    let functionName = tname + '$setFunction';

    return [
      [ functionName, {
        enumerable: false,
        value: tdescr.set,
      } ],
      [ tname, {
        get () {
          let atom = this[atomName]
            ?? makeDollarProp(this, atomName, createAtom(tname));
          atom.reportObserved();
          return Object.hasOwn(this, valueName)
            ? this[valueName]
            : this[valueName] = this[functionName]();
        },
        set (newValue) {
          let atom = this[atomName]
            ?? makeDollarProp(this, atomName, createAtom(tname));
          atom.reportChanged();
          return Object.hasOwn(this, valueName)
            ? this[valueName] = this[functionName](newValue)
            : makeDollarProp(this, valueName, this[functionName](newValue));
        },
      } ]
    ];
  }

  makeGetterDescriptorsFor (tname, tdescr) {
    let computedName = tname + '$computed';
    let getFn = tdescr.get;

    return [[ tname, {
      get () {
        return (this[computedName]
          ??= makeDollarProp(this, computedName, computed(getFn.bind(this)))
        ).get()
      },
    } ]];
  }

  makeDescriptorsFor (tname, tdescr) {

    if (tdescr.get && tdescr.set) {
      throw `Can't pass both get and set for Reactive() arg ${tname}`;
    }

    if (tdescr.value instanceof ReactivePropertyDescriptor) {
      tdescr = tdescr.value;
    }

    if ('value' in tdescr) {
      return this.makeValueDescriptorsFor(tname, tdescr);
    }

    if (tdescr.get) {
      return this.makeGetterDescriptorsFor(tname, tdescr);
    }

    if (tdescr.set) {
      return this.makeSetterDescriptorsFor(tname, tdescr);
    }

    throw "Wut";
  }

  makeClass () {
    let newName = 'Reactive' + this.superClass.name;

    return { [newName]: class extends this.superClass { } }[newName];
  }

  makeDescriptors () {
    return Object.entries(Object.getOwnPropertyDescriptors(this.tprops))
      .flatMap(([ k, v ]) => this.makeDescriptorsFor(k, v));
  }

  build () {
    let newClass = this.makeClass();

    let newProto = newClass.prototype;

    this.makeDescriptors().forEach(([ name, descr ]) =>
      Object.defineProperty(newProto, name, descr)
    );

    return newClass;
  }
}
