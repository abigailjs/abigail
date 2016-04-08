// dependencies
import AsyncEmitter from 'carrack';
import chopsticks from 'chopsticks';
import deepAssign from 'deep-assign';
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
  initialize(argv, options = { process }) {
    // eslint-disable-next-line no-unused-vars
    const { _, sentence, ...cliOptions } = chopsticks(argv, { sentence: true });
    if (cliOptions.version || cliOptions.v || cliOptions.V) {
      options.process.stdout.write(`${version}\n`);
      options.process.exit(0);
      return this;
    }

    const json = utils.lookupJson(options.cwd || process.cwd());
    const opts = Object.assign(
      {},
      this.constructor.defaultOptions || {},
      json.options || {},
    );

    const pluginOptions = deepAssign(
      {},
      utils.resolvePluginOptions(this.constructor.defaultOptions.plugins),
      utils.resolvePluginOptions(json.options.plugins),
      utils.resolvePluginOptions(cliOptions),
    );
    const plugins = utils.loadPlugins(this, pluginOptions);

    const sentenceWithLowdash = _.length ? sentence.concat([_]) : sentence;
    this.props = { sentence: sentenceWithLowdash, json, opts, pluginOptions, plugins };

    return this;
  }
}
