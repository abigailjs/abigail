// dependencies
import AsyncEmitter from 'carrack';
import assert from 'power-assert';
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
      assert(error.message === 'Unexpected token }');
    });
  });

  describe('.resolvePlugin', () => {
    it('in long name, it should return the constructor', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin('abigail-plugin-exit');
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'exit');
    });

    it('in short name, it should return the constructor', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin('exit');
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'exit');
    });

    it('if specify a path, should be require and returnes', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin(require.resolve('abigail-plugin-exit'));
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'exit');
    });

    it('if specify a constructor to the second argument, it should be returned as it is', () => {
      const emitter = new AsyncEmitter;
      const Plugin = utils.resolvePlugin(null, require('abigail-plugin-exit'));
      const plugin = new Plugin(emitter);
      assert(plugin.name === 'exit');
    });
  });

  describe('.loadPlugins', () => {
    // eslint-disable-next-line max-len
    it('key of the second argument as a plugin name, should be dependent on the first argument', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { exit: true });

      assert(plugins.exit.parent === emitter);
    });

    // eslint-disable-next-line max-len
    it('if specify false of the second argrument as a plugin value, should ignore the plugin', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { exit: false });

      assert(plugins.exit === undefined);
    });

    it('if specify value is object, should be a plugin option', () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { exit: { foo: 'bar' } });

      assert(plugins.exit.opts.value === undefined);
      assert(plugins.exit.opts.foo === 'bar');
    });

    it("if specifed value isn't boolean and object, should be a plugin `value` option", () => {
      const emitter = new AsyncEmitter;
      const plugins = utils.loadPlugins(emitter, { exit: 'guwa-!' });

      assert(plugins.exit.opts.value === 'guwa-!');
    });
  });
});
