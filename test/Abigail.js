// dependencies
import sinon from 'sinon';
import { join as joinPaths } from 'path';
import assert from 'power-assert';
import { version } from '../package.json';

// target
import { Abigail } from '../src';

// environment
const cwd = joinPaths(__dirname, 'fixtures', 'foo');

// fixture
const createProcess = () => ({
  cwd: () => process.cwd(),
  exit: sinon.spy(),
  stdout: {
    write: sinon.spy(),
  },
});

// specs
describe('Abigail', () => {
  describe('.initialize', () => {
    const simulateInitialize = (abigailArgv) => {
      const process = createProcess();

      new Abigail().initialize(abigailArgv, { cwd, process });

      return process;
    };

    it('output version, should be exit in 0', () => {
      let process;

      process = simulateInitialize(['-v']);
      assert(process.stdout.write.args[0][0] === `${version}\n`);
      assert(process.exit.args[0][0] === 0);

      process = simulateInitialize(['-V']);
      assert(process.stdout.write.args[0][0] === `${version}\n`);
      assert(process.exit.args[0][0] === 0);

      process = simulateInitialize(['--version']);
      assert(process.stdout.write.args[0][0] === `${version}\n`);
      assert(process.exit.args[0][0] === 0);
    });

    describe('pluginOptions', () => {
      // 1. Abigail.defaultOptions.plugins
      // 2. packageJson.abigail.plugins
      // 3. cliOptions(minimist)
      it('should merge the plugin options in the defined order', () => {
        const env = { cwd, process: createProcess() };
        const abigailArgv = ['--no-exit', '--launch', 'force', '--watch', 'foobarbaz'];
        const abigail = new Abigail().initialize(abigailArgv, env);
        const plugins = abigail.props.plugins;

        assert(plugins.exit === undefined);
        assert(plugins.launch);
        assert(plugins.launch.opts.bail === false);
        assert(plugins.log);
        assert(plugins.parse === undefined);

        assert(plugins.watch);
        assert(plugins.watch.opts.enable === true);
        assert(plugins.watch.opts.value === 'foobarbaz');
        assert(plugins.watch.opts.lazy === true);
      });
    });
  });
});
