import { getRegistry } from '../../util/moduleregistry.js'
import { tagBuilders, View, subviews } from '../viewcore.js'
import { Reactive } from '../reactive.js'

const { classes, R } = getRegistry(import.meta)

const { StringEditor } = classes

export { StringEditor }

const { form, input } = tagBuilders

R(class StringEditor extends Reactive(View, {
  value: ''
}) {

  onInput (event) { this.value = event.target.value }

  onSubmit (event) {
    event.preventDefault()
    this.onSave(this.value)
  }

  render () {
    const { onInput, onSubmit, value } = this;
    return form.inline({ onSubmit }, input({ onInput, value }));
  }
})
