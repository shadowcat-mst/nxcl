const jsFile = /^\/((?:src|sketches)\/.*\.js)$/;

Bun.serve({
  port: 4172,
  fetch (req) {
    let path = new URL(req.url).pathname;
    if (path == '/') {
      return new Response(Bun.file('sketches/server/index.html'));
    }
    let m = path.match(jsFile);
    if (m) {
      let jsPath = m[1];
      return new Response(Bun.file(jsPath));
    }
    return new Response('Nope', { status: 404 });
  }
});
