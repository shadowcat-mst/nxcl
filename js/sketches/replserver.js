import { staticHandler } from './server.js'
import { startNexus, websocketHandlers } from '../src/stupidrpc/bunserver.js'
import { opendir, readFile, writeFile } from 'node:fs/promises'

const storePath = 'var/repl'

const allowedStoreName = /^[a-zA-Z0-9_]+$/

const callHandlers = {
  async list () {
    const dir = await opendir(storePath), names = []
    for await (const dirent of dir) {
      const m = dirent.name.match(/^(.*?)\.json$/)
      if (m && m[1].match(allowedStoreName)) names.push(m[1])
    }
    return names.toSorted()
  },
  // not sure if I should be setting { encoding: 'utf8' } on both here
  // but hopefully for the moment 'neither' will at least work consistently
  async load (name) {
    if (!name.match(allowedStoreName)) throw "Invalid store name"
    const fileName = `${storePath}/${name}.json`
    return JSON.parse(await readFile(fileName))
  },
  async save (name, data) {
    if (!name.match(allowedStoreName)) throw "Invalid store name"
    const fileName = `${storePath}/${name}.json`
    await writeFile(fileName, JSON.stringify(data, null, 2) + '\n')
    return true
  }
}

function startCall (call, ...args) {
  if (!Object.hasOwn(callHandlers, call)) {
    throw `Invalid call name: ${call}`;
  }
  return callHandlers[call](...args)
}

if (import.meta.main) Bun.serve({
  port: 4172,
  fetch (req, server) {
    let path = new URL(req.url).pathname
    if (path == '/ws') {
      return startNexus(req, server, { startCall, debug: console })
    }
    return staticHandler(path) ?? new Response('Nope', { status: 404 })
  },
  websocket: websocketHandlers,
})
