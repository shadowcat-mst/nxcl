const staticFile = /(?<=^\/)(css|src|sketches)\/(.*)$/

export function staticHandler (path) {
  if (path == '/') {
    console.log('Serving: index')
    return new Response(Bun.file('sketches/server/index.html'))
  }
  if (path == '/favicon.ico') {
    console.log('Serving: favicon')
    return new Response(Bun.file('sketches/server/favicon.ico'))
  }
  const m = path.match(staticFile)
  if (m) {
    const staticPath = m[0]
    if (m[1] == 'src') {
      const bundlePath = `bundle/${m[2]}`
      if (Bun.file(bundlePath).size) staticPath = bundlePath
    } else if (m[1] == 'css') {
      staticPath = `sketches/server/css/${m[2]}`
    }
    console.log(`Serving: ${staticPath}`)
    return new Response(Bun.file(staticPath))
  }
  return
}

if (import.meta.main) Bun.serve({
  port: 4172,
  fetch (req) {
    const path = new URL(req.url).pathname
    return staticHandler(path) ?? new Response('Nope', { status: 404 })
  }
})
