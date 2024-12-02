import { observable, reaction, runInAction } from 'mobx'

import { preact } from '../src/web/libs.js'

import { VFrame } from '../src/web/views/vframe.js'

const { log } = console

const vframe = new VFrame()

reaction(
  () => vframe.render(),
  (v) => log(preact.renderToString(v, {}, { jsx: false })),
)

runInAction(() => vframe.content = "HI!")
