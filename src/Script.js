import { parse } from 'shell-quote';

export default class Script {
  constructor(name, raw) {
    this.name = name;
    this.raw = raw;
    this.parsed = parse(raw);
    this.canSpawn = this.parsed.reduce((can, op) => can && typeof op === 'string', true);
  }
}
