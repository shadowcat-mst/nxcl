import {
  render,
  h,
  options,
  Fragment,
} from 'preact'

import { default as jsxRenderToString } from 'preact-render-to-string/jsx'

const renderToString = v => jsxRenderToString(v, {}, { jsx: false })

// only things plugging in to preact should be accessing this so it gets its
// own separate export whereas the others are relatively common/normal usage

export { options as preactOptions }

export const preact = {
  render,
  h,
  Fragment,
  renderToString,
}

import {
  observable,
  action,
  flow,
  createAtom,
  reaction,
  Reaction
} from 'mobx'

import { observer } from 'mobx-preact'

export const mobx = {
  observable,
  action,
  flow,
  createAtom,
  reaction,
  Reaction,
  observer
}
