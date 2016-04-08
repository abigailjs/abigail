// dependencies
import { lookupSync } from 'climb-lookup';
import { dirname, resolve as resolvePaths } from 'path';
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
* @param {object} [args] - a key-value defines
* @returns {object} pluginOptions - the plugin options
*/
export function resolvePluginOptions(args = {}) {
  const pluginOptions = {};

  for (const key in args) {
    if (args.hasOwnProperty(key) === false) {
      continue;
    }
    if (args[key] === null || args[key] === undefined) {
      continue;
    }

    const fieldValue = args[key];
    if (typeof fieldValue === 'object') {
      pluginOptions[key] = fieldValue;
      continue;
    }

    const opts = {};
    if (typeof fieldValue === 'boolean') {
      opts.enable = fieldValue;
    }
    if (typeof fieldValue !== 'boolean') {
      opts.enable = true;
      opts.value = fieldValue;
    }
    pluginOptions[key] = opts;
  }

  return pluginOptions;
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
    return require(resolvePaths(process.cwd(), name));
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
    if (pluginOpts.enable === false) {
      continue;
    }

    const Plugin = resolvePlugin(name, pluginOpts);
    const plugin = new Plugin(parent, pluginOpts.value, pluginOpts);
    plugins[plugin.name] = plugin;
  }

  return plugins;
}

/**
* ['foo', 'bar.js'] -> {foo: true, 'bar.js': true}
*
* @param {string[]} args - a command line arguments
* @returns {object} pluginOptions
*/
export function toPluginOptions(args = []) {
  return args.reduce((object, arg) => Object.assign(object, { [arg]: true }), {});
}
