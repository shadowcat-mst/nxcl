import { observable, reaction, runInAction } from 'mobx'

let { log } = console

let spoo = observable({})

reaction(
  () => spoo.isTasty,
  (v) => log(`Is the spoo tasty? Magic eight ball says ${v}.`)
)

runInAction(() => spoo.isTasty = true)
runInAction(() => spoo.isTasty = false)
