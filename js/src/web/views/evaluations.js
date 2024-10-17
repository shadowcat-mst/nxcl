import { getRegistry } from '../../util/moduleregistry.js';
import { observable, action, makeObservable } from '../libs.js';
import { tagBuilders, View, ViewWithSubviews, Self } from '../viewcore.js';
import { TraceNode } from './trace.js';

let { classes, R } = getRegistry(import.meta);

const { EvaluationSeq, Evaluation } = classes;

export { EvaluationSeq };

let { div } = tagBuilders;

R(class Evaluation extends ViewWithSubviews({
  trace: TraceNode,
}) {

  get code () { return this.model.code }

  render () {
    return [
      div('$ ' + this.code),
      div(this.trace),
    ];
  }
});

R(class EvaluationSeq extends ViewWithSubviews({
  evaluations: [Evaluation]
}) {
  render () {
    return div(this.evaluations);
  }
});
