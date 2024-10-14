export let views = {};

function addViewTo (viewset, viewClass) {
  if (!viewClass.name) throw("https://trout.me.uk/data.jpg");
  viewset[viewClass.name] = viewClass;
}

export function registry (meta) {
  let urlObj = new URL(meta.url);
  // initial greedy .* ensures last /views/ part in URL just in case
  let m = urlObj.pathname.match(/.*\/views\/(.*?)\.js/);
  if (!m) throw "https://trout.me.uk/bunny.jpg";
  let parts = m[1].split('/');
  let viewset = views;
  for (let part of parts) viewset = viewset[part] ??= {};
  return {
    my: viewset,
    R: (...args) => addViewTo(viewset, ...args),
  };
}
