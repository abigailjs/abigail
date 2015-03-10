# ![abigail][.svg] Abigail [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Minimal task runner.

## Installation
```bash
npm install abigail --global
```

## Usage
```bash
abigail glob:script glob:script ...
```
* Pass `glob` to [chokidar][1]. React to changes(add,change,unlink) in the glob, And execute a `script`. 
* Can reuse your [npm script][2]. by ./package.json. (e.g. `abigail *.js:test`->`npm run test`)
* Execute raw-script if undefined a npm script. (e.g. `abigail *.md:'echo beep'` -> `echo beep`)

### `-e` `--execute`
Execute script after chokidar ready.
### `-i` `--ignore`
Using `~/.gitignore`&`./.gitignore`, Exclude from the glob.

## Example

### `lib/**/*.js:test`
```bash
abigail lib/**/*.js:test
#  +79 ms @ @ Using ./package.json
#  +83 ms @ @ Start watching lib/**/*.js for npm run test
#   +2sec @ @ File lib/hoge.js has been changed.
#   +0 ms @ @ Execute npm run test
# ...
#   +6sec @ @ Finished npm run test Exit code 0.
```

./package.json
```json
{
  "scripts":{
    "test":"mocha"
  },
  "devDependencies": {
    "mocha": "^2.2.1"
  }
}
```

### `lib/**/*.coffee:compile --execute`
```bash
abigail lib/**/*.coffee:compile -e
#  +79 ms @ @ Using ./package.json
#  +83 ms @ @ Start watching lib/**/*.coffee for npm run compile
#   +0 ms @ @ Execute npm run compile
# ...
#  +331ms @ @ Finished npm run compile Exit code 0.
```

./package.json
```json
{
  "scripts":{
    "compile":"coffee -o src -c lib"
  },
  "devDependencies": {
    "coffee-script": "^1.8.0"
  }
}
```

### `*.html:'chrome-cli reload'`
```bash
abigail *.html:'chrome-cli reload'
#  +89 ms @ @ Using ./package.json
# +107 ms @ @ Start watching *.html for chrome-cli reload
#   +1sec @ @ File README.html has been changed.
#   +0 ms @ @ Execute chrome-cli reload
#  +87 ms @ @ Finished chrome-cli reload, Exit code 0.
```
Use [chrome-cli][3], Like a LiveReload.

## TODO
* TEST

License
=========================
MIT by 59naga

[.svg]: https://cdn.rawgit.com/59naga/abigail/master/.svg

[npm-image]: https://badge.fury.io/js/abigail.svg
[npm]: https://npmjs.org/package/abigail
[travis-image]: https://travis-ci.org/59naga/abigail.svg?branch=master
[travis]: https://travis-ci.org/59naga/abigail
[coveralls-image]: https://coveralls.io/repos/59naga/abigail/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/abigail?branch=master

[1]: https://github.com/paulmillr/chokidar#getting-started
[2]: http://blog.ibangspacebar.com/npm-scripts/
[3]: https://github.com/prasmussen/chrome-cli
