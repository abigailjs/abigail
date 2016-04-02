// dependencies
import { lookupSync } from 'climb-lookup';
import { dirname } from 'path';
import { readFileSync } from 'fs';

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
    const data = { scripts: {} };
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

    const pluginOpts = options[name];
    if (pluginOpts.default === false) {
      continue;
    }

    const Plugin = resolvePlugin(name, pluginOpts);
    const plugin = new Plugin(parent, pluginOpts.default, pluginOpts);
    plugins[plugin.name] = plugin;
  }

  return plugins;
}
