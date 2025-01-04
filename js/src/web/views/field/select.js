import { mobx } from '../../libs.js'
import { Reactive } from '../../reactive.js'
import { View } from '../../viewcore.js'
import { getRegistry } from '../../../util/moduleregistry.js'

const { classes: { SelectField }, R } = getRegistry(import.meta)

export { SelectField }

R(class SelectField extends Reactive(View, {
  selectedValue: null,
  set attrs (v) { mobx.observable(v ?? {}) },
}) {

  onChange ({ target: { value } }) { this.selectedValue = value }

  render () {
    const {
      onChange, options, attrs, selectedValue, h: { select, option }
    } = this
    return select(
      { onChange, ...attrs },
      options.map(({ value, content }) => {
        const selected = selectedValue === value
        return option({ value, selected }, content)
      })
    )
  }
})
