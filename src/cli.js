// self dependencies
import Abigail from './Abigail';

/*
* abigail lifecycle (in serial)
*   initialized
*   parse
*   attach-plugins
*   (unless task) -> output logo && exit 1
*   launch
*     task-start (in parallel)
*       script-start
*       script-end
*       script-error
*     task-end
*   detach-plugins
*   exit
*   (all expection) -> output trace && exit 1
*/

/**
* @module abby
* @param {string[]} argv - a command line arguments
* @param {object} options - a override cli/json options
* @returns {undefined}
*/
export default (argv, options = {}) => {
  const abigail = new Abigail(options).initialize(argv);
  abigail.emit('initialized')
  .then(() => abigail.emit('parse'))
  .then(() => abigail.emit('attach-plugins'))
  .then(() => abigail.emit('launch'))
  .then(() => {
    if (abigail.listeners('exit').length) {
      return abigail.emit('detach-plugins')
      .then(() => abigail.emit('exit'));
    }

    return process.once('SIGINT', () => {
      try {
        abigail.props.plugins.log.abort();
      } catch (e) {
        // ignore
      }

      abigail.emit('detach-plugins')
      .then(() => abigail.emit('exit'));
    });
  })
  .catch((reason) => {
    console.trace(reason.message); // eslint-disable-line no-console
    process.exit(1);
  });
};
