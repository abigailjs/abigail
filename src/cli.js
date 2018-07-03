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
  abigail.emitParallel('initialized')
    .then(() => abigail.emitParallel('parse'))
    .then(() => abigail.emitParallel('attach-plugins'))
    .then(() => abigail.emitParallel('launch'))
    .then(() => {
      if (abigail.listeners('exit').length) {
        return abigail.emitParallel('detach-plugins')
          .then(() => abigail.emitParallel('exit'));
      }

      return process.once('SIGINT', () => {
        try {
          abigail.props.plugins.log.abort();
        } catch (e) {
        // ignore
        }

        abigail.emitParallel('detach-plugins')
          .then(() => abigail.emitParallel('exit'));
      });
    })
    .catch((reason) => {
      console.trace(reason.message); // eslint-disable-line no-console
      process.exit(1);
    });
};
