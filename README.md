# ![][.svg] Abigail [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> the Minimal task runner. Enhance your npm-scripts.

## Installation
```bash
$ npm install abigail --global
```

# CLI
```bash
$ abigail <script> <watch> [<script> <watch>...]
```

## Sequential scripts

Can specify the `<script>` separated by `,`.
Script executes sequentially.

```bash
$ abigail test,lint
# +141 ms @ @ Use ./package.json
#  +71 ms @ @ Watch test/** for test, lint.
#   +0 ms @ @ Begin test, lint ...
#   +2 ms @ @ Run test
# ...
#   +3sec @ @ Done test. Exit code 0.
#   +2 ms @ @ Run lint
# ...
#   +3sec @ @ Done test. Exit code 0.
#   +1 ms @ @ End test, lint. Exit code 0, 0.
$
```

## Multi glob

Can specify the `<watch>` separated by `,`.

```bash
$ abigail test *,src/**,test/**
#  +79 ms @ @ Use ./package.json
#  +82 ms @ @ Watch * and src/** and test/** for test
# +131 ms @ @ Run test
# ...
#   +7 ms @ @ Done test. Exit code 0.
#
#  +14sec @ @ File package.json added
#   +1 ms @ @ Run test
# ...
#   +7 ms @ @ Done test. Exit code 0.
#
#  +14sec @ @ File src/index.coffee changed
#   +1 ms @ @ Run test
# ...
#   +7 ms @ @ Done test. Exit code 0.
#
#  +14sec @ @ File test/api.spec.coffee deleted
#   +1 ms @ @ Run test
# ...
#   +7 ms @ @ Done test. Exit code 0.
```

## Sequential scripts & Multi glob

Can combine them.

```bash
$ abigail test,lint test/**,src/**
# +141 ms @ @ Use ./package.json
#  +71 ms @ @ Watch test/** and src/** for test, lint.
#   +0 ms @ @ Begin test, lint ...
#
#   +2 ms @ @ Run test
# ...
#   +3sec @ @ Done test. Exit code 0.
#   +2 ms @ @ Run lint
# ...
#   +3sec @ @ Done lint. Exit code 0.
#
#   +1 ms @ @ End test, lint. Exit code 0, 0.
#
#  +14sec @ @ File src/index.coffee changed
#   +0 ms @ @ Begin test, lint ...
# ...
```

# Options

## Package watch: Reserved word `PKG` of `<watch>`

`PKG` is expanded to `*`,`src/**`,`test/**`.

```bash
$ abigail test PKG
# +283 ms @ @ Use ./package.json
# +439 ms @ @ Watch * and src/** and test/** for test.
#   +2 ms @ @ Run test
# ...
```

## Lazy: prefix `_` of `<script>`

Can lazy execution if `<script>` has prefix `_`.

```bash
$ abigail _test test/**,src/**
#  +47 ms @ @ Use ./package.json
#  +50 ms @ @ Watch test/** and src/** for test.
#
#  +14sec @ @ File test/cli.spec.coffee changed
#   +1 ms @ @ Run test
# ...
```

## Exclude: prefix `_` of `<watch>`

Can omit a file from watch if `<watch>` has prefix `_`.

```bash
$ abigail test *,_node_modules/**
#  +43 ms @ @ Use ./package.json
#
#  +46 ms @ @ Watch ** and !node_modules/** for test.
# +898 ms @ @ Run test
# ...
```

## Raw script

Can use raw script if undefined in npm-scripts.

```bash
$ abigail "echo foo" test/**
#   +47 ms @ @ Use ./package.json
#   +49 ms @ @ Watch test/cli.spec.coffee for echo foo
#  +126 ms @ @ Run echo foo
# foo
#    +7 ms @ @ Done echo foo. Exit code 0.
```

## Note

Doesn't use the variable deployment & `npm run`.
Because _abigail prefer to speed and compatibility_.

> This matter is better to [onchange](https://www.npmjs.com/package/onchange).

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
