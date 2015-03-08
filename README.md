# ![abigail][.svg] Abigail [![NPM version][npm-image]][npm] [![Bower version][bower-image]][bower] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Minimal task runner.

## Installation
```bash
npm install abigail --global
```

## Usage
```bash
  Usage:
    abigail glob:script glob:script ...

  Options:
    -e --execute : Execute script after ready
    -i --ignore  : Using .gitignore, Exclude from the glob

  Example:
    $ abigail *.coffee:compile
      > @ @ Start watching *.coffee for npm run compile

    $ abigail *.coffee:compile --execute
      > @ @ Start watching  *.coffee for npm run compile
      > @ @ Execute npm run compile

    $ abigail *.md:'echo cool'
      > @ @ Start watching *.md for echo cool

    $ abigail **/*.jade:'$(npm bin)/jade test/viaAvigail.jade -o .'
      > @ @ Start watching **/*.jade for $(npm bin)/jade test/viaAvigail.jade -o .
```

License
=========================
MIT by 59naga

[.svg]: https://cdn.rawgit.com/59naga/abigail/master/.svg?

[npm-image]: https://badge.fury.io/js/abigail.svg
[npm]: https://npmjs.org/package/abigail
[bower-image]: https://badge.fury.io/bo/abigail.svg
[bower]: http://badge.fury.io/bo/abigail
[travis-image]: https://travis-ci.org/59naga/abigail.svg?branch=master
[travis]: https://travis-ci.org/59naga/abigail
[coveralls-image]: https://coveralls.io/repos/59naga/abigail/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/abigail?branch=master