import { getRegistry } from '../../util/moduleregistry.js'
import { View, subviews } from '../viewcore.js'
import { Reactive } from '../reactive.js'

const { classes: { StringEditor }, R } = getRegistry(import.meta)

export { StringEditor }

R(class StringEditor extends Reactive(View, {
  value: ''
}) {

  onInput (event) { this.value = event.target.value }

  onSubmit (event) {
    event.preventDefault()
    this.onSave(this.value)
  }

  render () {
    const { onInput, onSubmit, value, h: { form, input } } = this;
    return form.inline({ onSubmit }, input({ onInput, value }));
  }
})
