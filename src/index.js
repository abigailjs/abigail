import 'source-map-support/register';
import npmPath from 'npm-path';

// update process.env
npmPath();

export { default as Abigail } from './Abigail';
export cli from './cli';
export * as utils from './utils';
