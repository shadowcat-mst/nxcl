const jsFile = /(?<=^\/)(src|sketches)\/(.*\.js)$/;

Bun.serve({
  port: 4172,
  fetch (req) {
    let path = new URL(req.url).pathname;
    if (path == '/') {
      console.log('Serving: index');
      return new Response(Bun.file('sketches/server/index.html'));
    }
    let m = path.match(jsFile);
    if (m) {
      let jsPath = m[0];
      if (m[1] == 'src') {
        let bundlePath = `bundle/${m[2]}`;
        if (Bun.file(bundlePath).size) jsPath = bundlePath;
      }
      console.log(`Serving: ${jsPath}`);
      return new Response(Bun.file(jsPath));
    }
    return new Response('Nope', { status: 404 });
  }
});
