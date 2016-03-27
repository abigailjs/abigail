// dependencies
import AsyncEmitter from 'carrack';
import minimist from 'minimist';
import * as utils from './utils';

import { version } from '../package.json';

/**
* @extends AsyncEmitter
* @class Abigail
*/
export default class Abigail extends AsyncEmitter {
  // @static
  // @property defaultOptions
  static defaultOptions = {
    plugins: {
      exit: true,
      launch: true,
      log: true,
      parse: true,
      watch: true,
    },
  }

  /**
  * @method initialize
  * @param {array} argv - a command line arguments
  * @param {object} options - a abigail options
  * @returns {abigail} this - the self instance
  */
  initialize(argv, options = {}) {
    const { _: globs, ...cliOptions } = minimist(argv);// eslint-disable-line
    if (cliOptions.version || cliOptions.v || cliOptions.V) {
      process.stdout.write(`${version}\n`);
      process.exit(0);
    }

    const json = utils.lookupJson(options.cwd || process.cwd());
    const opts = Object.assign(
      {},
      this.constructor.defaultOptions || {},
      json.options || {},
      options || {},
    );
    const pluginOptions = Object.assign(
      {},
      this.constructor.defaultOptions.plugins || {},
      json.options.plugins || {},
      cliOptions || {},
      options.plugins || {},
    );
    const plugins = utils.loadPlugins(this, pluginOptions);

    this.props = { globs, json, opts, pluginOptions, plugins };

    return this;
  }
}
