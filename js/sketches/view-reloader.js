export function reloadViewSet (type) {
  let urlObj = new URL(`src/web/views/${type}.js`);
  urlObj.search = `ts=${Date.now()}`;
  import(urlObj.toString());
}
