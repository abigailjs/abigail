// dependencies
import AsyncEmitter from 'carrack';
import flattenDeep from 'lodash.flattendeep';
import assert from 'power-assert';
import Script from '../src/Script';
import { join as joinPaths } from 'path';

// target
import { utils } from '../src';

// fixture
import { scripts } from './fixtures/foo/package.json';

// environment
const cwd = joinPaths(__dirname, 'fixtures', 'foo');

// specs
describe('utils', () => {
  describe('.normalize', () => {
    it('comma should be converted to one of the command linked', () => {
      const expected = 'test1,test2';

      let normalize;
      normalize = utils.normalize(['test1,', 'test2']).join(' ');
      assert(normalize === expected);
      normalize = utils.normalize(['test1', ',test2']).join(' ');
      assert(normalize === expected);
      normalize = utils.normalize(['test1', ',', 'test2']).join(' ');
      assert(normalize === expected);
      normalize = utils.normalize(['test1,test2', '']).join(' ');
      assert(normalize === expected);
      normalize = utils.normalize(['test1,test2', ',', ',']).join(' ');
      assert(normalize === expected);

      // do not change a quoted shell script eg "test , test"
      normalize = utils.normalize(['test , test']).join(' ');
      assert(normalize !== expected);
    });
  });

  describe('.createSerial', () => {
    it('should return the match to script in the Script instance to the `main`', () => {
      const { main } = utils.createSerial('test1', scripts);
      assert(main instanceof Script);
      assert(main.name === 'test1');
    });

    it('if `pre` / `post` exists, it should be returned to the same name of the field', () => {
      const { main, pre, post } = utils.createSerial('other', scripts);
      assert(main instanceof Script);
      assert(main.name === 'other');
      assert(pre instanceof Script);
      assert(pre.name === 'preother');
      assert(post instanceof Script);
      assert(post.name === 'postother');
    });
  });

  describe('.parse', () => {
    it('should return the script to match the name in a 3d array', () => {
      const task = utils.parse(['test1'], scripts);

      assert(flattenDeep(task).length === 1);
      assert(task[0][0][0].main.name === 'test1');
    });

    it('if script is not found, should throw the error ', () => {
      let error = {};
      try {
        utils.parse(['nothing'], scripts);
      } catch (e) {
        error = e;
      }
      assert(error.message === 'no scripts found: nothing');
    });

    it('comma should be pushed in the 2d of the array', () => {
      const task = utils.parse(['test1', ',', 'test2'], scripts);

      assert(flattenDeep(task).length === 2);
      assert(task[0][0][0].main.name === 'test1');
      assert(task[0][1][0].main.name === 'test2');
    });

    it('pre, post should be defined in the same name field', () => {
      const task = utils.parse(['other'], scripts);

      assert(flattenDeep(task).length === 1);
      assert(task[0][0][0].pre.name === 'preother');
      assert(task[0][0][0].main.name === 'other');
      assert(task[0][0][0].post.name === 'postother');
    });

    it('comma should be pushed in the 2d of the array', () => {
      const task = utils.parse(['test1', ',', 'test2'], scripts);

      assert(flattenDeep(task).length === 2);
      assert(task[0][0][0].main.name === 'test1');
      assert(task[0][1][0].main.name === 'test2');
    });

    it('should processed in parallel unless adjacent to comma(in 1d of the array)', () => {
      let task;

      task = utils.parse(['test*', 'test1', ',', 'test2'], scripts);
      assert(task[0][0][0].main.name === 'test1');
      assert(task[0][0][1].main.name === 'test2');
      assert(task[1][0][0].main.name === 'test1');
      assert(task[1][1][0].main.name === 'test2');

      task = utils.parse([',other', 'test1', ',', 'test2'], scripts);
      assert(task[0][0][0].main.name === 'other');
      assert(task[0][0][0].pre.name === 'preother');
      assert(task[0][0][0].post.name === 'postother');
      assert(task[1][0][0].main.name === 'test1');
      assert(task[1][1][0].main.name === 'test2');
    });

    xit('TODO: shell script is not supported', () => {
      utils.parse(['echo "test1 , test2"'], scripts);
    });
  });

  describe('.lookupJson', () => {
    it('should return the closest of json information', () => {
      const json = utils.lookupJson(cwd);
      assert(json.path === joinPaths(cwd, 'package.json'));
      assert(json.data.scripts);
    });

    it('if no found json, should return the empty information', () => {
      const json = utils.lookupJson('/');
      assert(json.path === null);
      assert(json.data.scripts === undefined);
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
