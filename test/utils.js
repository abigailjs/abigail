// dependencies
import AsyncEmitter from 'carrack';
import assert from 'power-assert';
import { join as joinPaths } from 'path';

// target
import * as utils from '../src/utils';

// environment
const cwd = joinPaths(__dirname, 'fixtures', 'foo');

// specs
describe('utils', () => {
  describe('.lookupJson', () => {
    it('should return the closest of json information', () => {
      const json = utils.lookupJson(cwd);
      assert(json.path === joinPaths(cwd, 'package.json'));
      assert(Object.keys(json.data.scripts).length > 0);
    });

    it('if no found json, should return the empty information', () => {
      const json = utils.lookupJson('/');
      assert(json.path === null);
      assert(Object.keys(json.data.scripts).length === 0);
    });

    it('if json parse failure should throw an exception', () => {
      let error;
      try {
        utils.lookupJson(joinPaths(__dirname, 'fixtures', 'bar'));
      } catch (e) {
        error = e;
      }
      assert(error.message === 'Unexpected token }');
    });
  });

  describe('.resolvePlugin', () => {
    it('in long name, it should return the constructor', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin('abigail-plugin-parse');
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });

    it('in short name, it should return the constructor', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin('parse');
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });

    it('if specify a path, should be require and returnes', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin(require.resolve('abigail-plugin-parse'));
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });

    it('if specify a constructor to the second argument, it should be returned as it is', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin(null, require('abigail-plugin-parse'));
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });
  });

  describe('.loadPlugins', () => {
    it('if specify pluginOpts is false, should be a plugin disable', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: false });

      assert(plugins.parse === undefined);
    });

    it('if specify pluginOpts.default is true, should be a plugin enable', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: { default: true } });

      assert(plugins.parse.parent === emitter);
    });

    it('if specify pluginOpts.default is false, should be a plugin disable', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: { default: false } });

      assert(plugins.parse === undefined);
    });

    it('if specify pluginOpts.default isnt boolean, should be a plugin opts', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: { default: 'foo' } });

      assert(plugins.parse.opts.default === 'foo');
      assert(plugins.parse.opts.value === 'foo'); // deprecated
    });
  });
});
