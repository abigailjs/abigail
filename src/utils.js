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
* @param {boolean} [options] - a extra behaviors
* @param {boolean} [options.enableIfObject=false] - if true and fieldValue is object, plugin to enable
* @returns {object} pluginOptions - the plugin options
*/
export function resolvePluginOptions(args = {}, options = { enableIfObject: false }) {
  const pluginOptions = {};

  Object.keys(args).forEach(key => {
    if (args.hasOwnProperty(key) === false) {
      return;
    }
    if (args[key] === null || args[key] === undefined) {
      return;
    }

    const fieldValue = args[key];
    if (typeof fieldValue === 'object') {
      if (options.enableIfObject) {
        fieldValue.enable = true;
      }
      pluginOptions[key] = fieldValue;
      return;
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
  });

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

  Object.keys(options).forEach(name => {
    if (options.hasOwnProperty(name) === false) {
      return;
    }

    const pluginOpts = options[name];
    if (pluginOpts.enable === false) {
      return;
    }

    const Plugin = resolvePlugin(name, pluginOpts);
    const plugin = new Plugin(parent, pluginOpts.value, pluginOpts);
    plugins[plugin.name] = plugin;
  });

  return plugins;
}
