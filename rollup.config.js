import npm from 'rollup-plugin-npm';
import commonjs from 'rollup-plugin-commonjs';
import babel from 'rollup-plugin-babel';
import json from 'rollup-plugin-json';
import uglify from 'rollup-plugin-uglify';
import pascalCase from 'pascal-case';

export default {
  entry: 'src/index.js',
  dest: 'lib/index.js',
  sourceMap: true,
  format: 'umd',
  moduleName: pascalCase(require('./package.json').name),
  plugins: [
    npm({
      jsnext: true,
      skip: [
        'abigail-plugin',
        'abigail-plugin-exit',
        'abigail-plugin-launch',
        'abigail-plugin-log',
        'abigail-plugin-parse',
        'abigail-plugin-watch',
        'source-map-support',
      ],
    }),
    commonjs(),
    json(),
    babel(),
    uglify(),
  ],
};
