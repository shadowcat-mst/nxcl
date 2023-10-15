export class Scope {
  constructor ({ proto }) {
    this.scope = Object.create(proto === undefined ? null : proto);
  }

  *at (name) { this.scope[name] }
}
