import { getRegistry } from '../../util/moduleregistry.js';
import { tagBuilders, View, subviews } from '../viewcore.js';
import { Reactive } from '../reactive.js';
import { TraceNode } from './trace.js';
import { StringEditor } from './stringeditor.js';

let { classes, R } = getRegistry(import.meta);

const { EvaluationSeq, Evaluation } = classes;

export { EvaluationSeq };

let { div } = tagBuilders;

R(class Evaluation extends Reactive(View, {
  editor: null,
  ...subviews({
    trace: TraceNode,
  }),
  saveEditedValue (value) {
    this.code = value;
    this.editor$value = null;
  },
  edit () {
    this.editor = new StringEditor({
      value: this.code,
      onSave: this.saveEditedValue
    })
  }
}) {

  get code () { return this.model.code }
  set code (v) { this.model.code = v }

  renderCode () {
    if (this.editor) return [ '$ ', this.editor ]
    const onClick = this.edit;
    return [ { onClick }, '$ ' + this.code ];
  }

  render () {
    return [
      div(...this.renderCode()),
      div(this.trace ?? '[...]'),
    ];
  }
});

R(class EvaluationSeq extends Reactive(View, {
  appendEditor: {
    builder () { return this.makeAppendEditor() },
    writable: true
  },
  saveFromAppendEditor (code) {
    this.model.evaluations.push({ code });
    this.appendEditor = this.makeAppendEditor()
  },
  ...subviews({ evaluations: [Evaluation] })
}) {

  makeAppendEditor () {
    return new StringEditor({
      onSave: this.saveFromAppendEditor
    })
  }

  render () {
    return div(this.evaluations, div('$ ', this.appendEditor));
  }
});
