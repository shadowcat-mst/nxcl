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

  let newName = 'Reactive' + superClass.name;

  let newClass = {
    [newName]: class extends superClass { },
  }[newName];

  function newProp (name, descr) {
    Object.defineProperty(newClass.prototype, name, descr);
  }

  for (let [ tname, tdescr ] of ownEntries(tprops)) {

    if (tdescr.get && tdsecr.set) {
      throw `Can't pass both get and set for Reactive() arg ${tname}`;
    }

    if (tdescr.value instanceof ReactivePropertyDescriptor) {
      tdescr = tdescr.value;
    }

    if ('value' in tdescr) {

      let tvalue = tdescr.value;

      if (typeof tvalue == 'function') {

        let actionName = tname + '$action';

        // action() and flow() both pass through 'this'

        let actionFn = (
          tvalue instanceof GeneratorFunction
            ? flow(tvalue)
            : action(tvalue)
        );

        newProp(tname, {
          enumerable: false,
          get () {
            return this[actionName]
              ?? makeDollarProp(this, actionName, actionFn.bind(this))
          },
        });

      } else if (typeof tvalue == 'object') {

        throw `Can't pass object value for Reactive() arg ${tname}; try set`;

      } else {

        let atomName = tname + '$atom', valueName = tname + '$value';

        newProp(tname, {
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
        });
      }

    } else if (tdescr.set) {

      let atomName = tname + '$atom', valueName = tname + '$value';
      let setFn = tdescr.set;

      newProp(tname, {
        get () {
          let atom = this[atomName]
            ?? makeDollarProp(this, atomName, createAtom(tname));
          atom.reportObserved();
          return Object.hasOwn(this, valueName)
            ? this[valueName]
            : this[valueName] = setFn.call(this);
        },
        set (newValue) {
          let atom = this[atomName]
            ?? makeDollarProp(this, atomName, createAtom(tname));
          atom.reportChanged();
          return Object.hasOwn(this, valueName)
            ? this[valueName] = setFn.call(this, newValue)
            : makeDollarProp(this, valueName, setFn.call(this, newValue));
        },
      });

    } else if (tdescr.get) {

      let computedName = tname + '$computed';
      let getFn = tdescr.get;

      newProp(tname, {
        get () {
          return (this[computedName]
            ??= makeDollarProp(this, computedName, computed(getFn.bind(this)))
          ).get()
        },
      });

    } else {
      // Notreached?
      throw `No value, get or set in ${tname}`;
    }
  }
  return newClass;
}
