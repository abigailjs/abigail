import npmPath from 'npm-path';

// update process.env
npmPath();

export { default as Abigail } from './Abigail';
export * as utils from './utils';
