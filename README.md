# ![][.svg] Abigail [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> the Minimal task runner. Enhance your npm-scripts.

## Installation
```bash
$ npm install abigail --global
```

# CLI
```bash
$ abigail <script-name> <watch> [<script-name> <watch>...]
```

## Multi globs

Can specify the watch separated by commas.

```bash
$ abigail test test/**,src/**
#  +79 ms @ @ Use ./package.json
#  +82 ms @ @ Watch test/** and src/** for npm run test
# +131 ms @ @ Execute npm run test
# ...
#   +6sec @ @ Finished $ npm run test Exit code 0.
#  +14sec @ @ File test/cli.spec.coffee changed
# ...
```

## Script prefix `_`

Can lazy execution if prefix `_` for `<script-name>`.

```bash
$ abigail _test test/**,src/**
#  +47 ms @ @ Use ./package.json
#  +50 ms @ @ Watch test/** and src/** for npm run test.
#  +14sec @ @ File test/cli.spec.coffee changed
```

## Watch prefix `_`

Can omit a file from watch if prefix `_` for `<watch>`.

```bash
$ abigail test **,_node_modules/**
#  +43 ms @ @ Use ./package.json
#  +46 ms @ @ Watch ** and !node_modules/** for npm run test.
# +898 ms @ @ Execute npm run test
# ...
```

## Raw script

Can use raw script if undefined npm-scripts.

```bash
$ abigail "echo foo" test/**
#   +47 ms @ @ Use ./package.json
#   +49 ms @ @ Watch test/cli.spec.coffee for echo foo
#  +126 ms @ @ Execute echo foo
# foo
#    +7 ms @ @ Finish echo foo, Exit code 0.
```

License
=========================
[MIT][License]

[License]: http://59naga.mit-license.org/

[.svg]: https://cdn.rawgit.com/59naga/abigail/master/.svg

[npm-image]: https://badge.fury.io/js/abigail.svg
[npm]: https://npmjs.org/package/abigail
[travis-image]: https://travis-ci.org/59naga/abigail.svg?branch=master
[travis]: https://travis-ci.org/59naga/abigail
[coveralls-image]: https://coveralls.io/repos/59naga/abigail/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/abigail?branch=master