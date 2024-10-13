export function reloadAll () {
  let cssLinks = document.querySelectorAll('head > link[rel="stylesheet"]');
  for (let link of cssLinks) {
    reload(link);
  }
}

let amReloadingThis = Symbol('amReloadingThis');

export function reload (link) {

  if (link[amReloadingThis]) return;
  link[amReloadingThis] = true;

  let newLink = link.cloneNode(false);
  {
    let urlObj = new URL(newLink.href);
    urlObj.search = `ts=${Date.now()}`;
    newLink.href = urlObj.toString();
  }

  let parent = link.parentNode;

  newLink.onload = () => { parent.removeChild(link) };

  parent.insertBefore(newLink, link);
}
