// dependencies
import AsyncEmitter from 'carrack';
import assert from 'assert';
import { join as joinPaths } from 'path';

// target
import { utils } from '../src';

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
      assert(error.message.match(/^Unexpected token }/));
    });
  });

  describe('.resolvePluginOptions', () => {
    it('if the value is undefined, it should not return the options', () => {
      const opts = utils.resolvePluginOptions({ foo: undefined });
      assert(opts.foo === undefined);
    });

    it('if the value is boolean, it should be returned as enable', () => {
      const opts = utils.resolvePluginOptions({ foo: true });
      assert(opts.foo.enable === true);
      assert(opts.foo.value === undefined);
    });

    it('if the value isnt boolean, it should be returned as value', () => {
      const opts = utils.resolvePluginOptions({ foo: 'bar' });
      assert(opts.foo.enable === true);
      assert(opts.foo.value === 'bar');
    });

    it('if the value is an object, to be returned as it is', () => {
      let opts;

      opts = utils.resolvePluginOptions({ foo: { enable: true } });
      assert(opts.foo.enable === true);
      assert(opts.foo.value === undefined);

      opts = utils.resolvePluginOptions({ foo: { enable: 'baz' } });
      assert(opts.foo.enable === 'baz');
      assert(opts.foo.value === undefined);

      opts = utils.resolvePluginOptions({ foo: { value: 'baz' } });
      assert(opts.foo.enable === undefined);
      assert(opts.foo.value === 'baz');
    });
  });

  describe('.resolvePlugin', () => {
    it('in long name, it should return the constructor', () => {
      const emitter = new AsyncEmitter();
      const Plugin = utils.resolvePlugin('abigail-plugin-parse');
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });

    it('in short name, it should return the constructor', () => {
      const emitter = new AsyncEmitter();
      const Plugin = utils.resolvePlugin('parse');
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });

    it('if specify a path, should be require and returnes', () => {
      const emitter = new AsyncEmitter();
      const Plugin = utils.resolvePlugin(require.resolve('abigail-plugin-parse'));
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });

    it('if specify a constructor to the second argument, it should be returned as it is', () => {
      const emitter = new AsyncEmitter();
      const Plugin = utils.resolvePlugin(null, require('abigail-plugin-parse'));
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'parse');
    });
  });

  describe('.loadPlugins', () => {
    it('if specify pluginOpts.enable is true, should be a plugin enable', () => {
      const emitter = new AsyncEmitter();
      const plugins = utils.loadPlugins(emitter, { parse: { enable: true } });

      assert(plugins.parse.parent === emitter);
    });

    it('if specify pluginOpts.enable is false, should be a plugin disable', () => {
      const emitter = new AsyncEmitter();
      const plugins = utils.loadPlugins(emitter, { parse: { enable: false } });

      assert(plugins.parse === undefined);
    });
  });
});
