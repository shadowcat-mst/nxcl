const staticFile = /(?<=^\/)(css|src|sketches)\/(.*)$/;

Bun.serve({
  port: 4172,
  fetch (req) {
    let path = new URL(req.url).pathname;
    if (path == '/') {
      console.log('Serving: index');
      return new Response(Bun.file('sketches/server/index.html'));
    }
    if (path == '/favicon.ico') {
      console.log('Serving: favicon');
      return new Response(Bun.file('sketches/server/favicon.ico'));
    }
    let m = path.match(staticFile);
    if (m) {
      let staticPath = m[0];
      if (m[1] == 'src') {
        let bundlePath = `bundle/${m[2]}`;
        if (Bun.file(bundlePath).size) staticPath = bundlePath;
      } else if (m[1] == 'css') {
        staticPath = `sketches/server/css/${m[2]}`;
      }
      console.log(`Serving: ${staticPath}`);
      return new Response(Bun.file(staticPath));
    }
    return new Response('Nope', { status: 404 });
  }
});
