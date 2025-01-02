import { staticHandler } from './server.js'
import { startNexus, websocketHandlers } from '../src/stupidrpc/bunserver.js'
import { readFile, writeFile } from 'node:fs/promises'

const storePath = 'var/repl'

const callHandlers = {
  async load (name) {
    const fileName = `${storePath}/${name}.json`
    return JSON.parse(await readFile(fileName, { encoding: 'utf8' }))
  },
  async save (name, data) {
    const fileName = `${storePath}/${name}.json`
    await writeFile(fileName, JSON.stringify(data, null, 2))
    return true
  }
}

if (import.meta.main) Bun.serve({
  port: 4172,
  fetch (req, server) {
    const path = new URL(req.url).pathname
    if (path == '/ws') return startNexus(req, server, callHandlers)
    return staticHandler(path) ?? new Response('Nope', { status: 404 })
  },
  websocket: websocketHandlers,
})
