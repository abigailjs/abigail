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
      log: true,
      launch: true,
      watch: true,
    },
  }

  /**
  * @method parse
  * @param {array} argv - a command line arguments
  * @param {object} options - a abigail options
  * @returns {abigail} this - the self instance
  */
  parse(argv, options = {}) {
    const { _: globs, ...cliOptions } = minimist(argv);// eslint-disable-line

    if (cliOptions.version || cliOptions.v || cliOptions.V) {
      process.stdout.write(`${version}\n`);
      process.exit(0);
    }

    this.json = utils.lookupJson(options.cwd || process.cwd());
    this.task = utils.parse(globs, this.json.data.scripts);
    this.opts = Object.assign(
      {},
      this.constructor.defaultOptions || {},
      this.json.options || {},
      options || {},
    );
    this.pluginOptions = Object.assign(
      {},
      this.constructor.defaultOptions.plugins || {},
      this.json.options.plugins || {},
      cliOptions || {},
      options.plugins || {},
    );

    this.plugins = utils.loadPlugins(this, this.pluginOptions);

    return this;
  }
}
