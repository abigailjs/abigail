import minimatch from 'minimatch';
import { lookupSync } from 'climb-lookup';
import { dirname } from 'path';
import { readFileSync } from 'fs';

import Script from './Script';

/**
* @param {string[]} argv - a command line arguments
* @returns {string[]} nomarlized - the script globs
*/
export function normalize(argv) {
  const normalized = [];

  let nextSerial = false;
  argv.forEach((arg) => {
    const name = arg.replace(/(^,|,$)/, '');

    const existsSerialPrev = arg[0] === ',' && normalized.length && name.length;
    const canSerialJoin = nextSerial && normalized.length && name.length;
    if (existsSerialPrev || canSerialJoin) {
      nextSerial = false;
      normalized[normalized.length - 1] += `,${name}`;
      return;
    }

    if (arg.slice(-1) === ',') {
      nextSerial = true;
    }
    if (name.length === 0) {
      return;
    }

    normalized.push(name);
  });

  return normalized;
}

/**
* @param {string} key - a script name
* @param {object} scripts - a source npm scripts
* @returns {object} serial - the matched script with pre and post scripts
*/
export function createSerial(key, scripts) {
  const main = new Script(key, scripts[key]);

  const preKey = `pre${key}`;
  let pre;
  if (scripts[preKey]) {
    pre = new Script(preKey, scripts[preKey]);
  }

  const postKey = `post${key}`;
  let post;
  if (scripts[postKey]) {
    post = new Script(postKey, scripts[postKey]);
  }

  return { pre, main, post };
}

/**
* @param {string[]} argv - a command line arguments
* @param {object} packageScripts - a source npm scripts
* @returns {array} task - the represents the execution order of the script
*   task[]             - run in parallel
*   task[][]           - run in serial
*   task[][][]         - run in parallel
*   task[][][].scripts - run in serial ({pre, main, post})
*/
export function parse(argv = [], scripts = {}) {
  const task = [];

  normalize(argv).forEach((arg) => {
    const serial = [];

    arg.split(',').forEach((pattern) => {
      const parallel = [];

      for (const key in scripts) {
        if (minimatch(key, pattern)) {
          parallel.push(createSerial(key, scripts));
        }
      }

      if (parallel.length === 0) {
        throw new Error(`no scripts found: ${pattern}`);
      } else {
        serial.push(parallel);
      }
    });

    if (serial.length === 0) {
      throw new Error(`no scripts found: ${arg}`);
    } else {
      task.push(serial);
    }
  });

  return task;
}

/**
* @param {string} cwd - a starting position
* @returns {object} information - the lookup result
*/
export function lookupJson(cwd) {
  let path;
  try {
    path = lookupSync('package.json', { cwd });
  } catch (e) {
    path = null;
    const dir = null;
    const data = {};
    const options = {};

    return { path, dir, data, options };
  }

  const dir = dirname(path);
  const data = JSON.parse(readFileSync(path));
  const options = data.abigail || {};

  return { path, dir, data, options };
}

/**
* @param {string} name - a plugin name
* @param {function} [constructor=undefined] - a plugin constructor
* @returns {function} constructor - the plugin constructor
*/
export function resolvePlugin(name, constructor) {
  if (typeof constructor === 'function') {
    return constructor;
  }
  if (name.match(/^[\w\-]+$/) === null) {
    return require(name);
  }
  if (name.match(/^abigail-plugin/)) {
    return require(name);
  }

  return require(`abigail-plugin-${name}`);
}

/**
* @param {AsyncEmitter} parent - a abigail instance
* @param {object} options - a name-option as key-value for plugin
* @returns {object} plugins - the plugin instances
*/
export function loadPlugins(parent, options = {}) {
  const plugins = {};

  for (const name in options) {
    if (options.hasOwnProperty(name) === false) {
      continue;
    }

    const value = options[name];
    if (value === false) {
      continue;
    }

    const Plugin = resolvePlugin(name, value);
    const pluginValue = typeof value !== 'object' ? value : undefined;
    const pluginOptions = typeof value === 'object' ? value : undefined;
    const plugin = new Plugin(parent, pluginValue, pluginOptions);
    plugins[plugin.name] = plugin;
  }

  return plugins;
}
