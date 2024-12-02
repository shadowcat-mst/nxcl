import {
  render,
  h,
  options,
  Fragment,
} from 'preact'

import { default as jsxRenderToString } from 'preact-render-to-string/jsx'

const renderToString = v => jsxRenderToString(v, {}, { jsx: false })

export { options as preactOptions }

export const preact = {
  render,
  h,
  Fragment,
  renderToString,
}

import { observable, action, flow, createAtom, Reaction } from 'mobx'
import { observer } from 'mobx-preact'

export const mobx = {
  observable, action, flow, createAtom, Reaction, observer
}
