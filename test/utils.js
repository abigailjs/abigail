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
    // eslint-disable-next-line max-len
    it('key of the second argument as a plugin name, should be dependent on the first argument', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: true });

      assert(plugins.parse.parent === emitter);
    });

    // eslint-disable-next-line max-len
    it('if specify false of the second argrument as a plugin value, should ignore the plugin', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: false });

      assert(plugins.parse === undefined);
    });

    it('if specify value is object, should be a plugin option', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: { foo: 'bar' } });

      assert(plugins.parse.opts.value === undefined);
      assert(plugins.parse.opts.foo === 'bar');
    });

    it('if specify value.default is false, should be a plugin disable', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: { default: false } });

      assert(plugins.parse === undefined);
    });

    it("if specifed value isn't boolean and object, should be a plugin `value` option", () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { parse: 'guwa-!' });

      assert(plugins.parse.opts.value === 'guwa-!');
    });
  });
});
