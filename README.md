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

## fork and pending

When `abigail` receives a filename, it will attempt to run with a [child_process.fork](https://nodejs.org/api/child_process.html).

If receive a `{abigail:'pending'}` from the task, then leave the task and start the next task.

When the sequential tasks is complete, kill the left task(handled as 0).

```bash
$ abigail server.js,test
# +  73 ms @ @ Use ./package.json
# +   5 ms @ @ Begin server.js, test ...
# +   4 ms @ @ Run server.js
# Server running at http://localhost:59798/
# + 190 ms @ @ Pending server.js.
# +   1 ms @ @ Run test
# ...
# +   2  s @ @ Done test. Exit code 0.
# +   1 ms @ @ End server.js, test. Exit code 0, 0.
```

```js
// server.js
var express= require('express')
var app= express()
app.static(express.static(__dirname+'/test/fixtures'))
app.listen(59798,function(){
  console.log('Server running at http://localhost:59798/')
  process.send({abigail:'pending'})
})
```

# Options

## Package watch: Keyword `PKG` of `<watch>`

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

## Force execution: `--force`, `-f`

Ignore the failure. Run the sequential scripts to the end.

```bash
$ abigail lint,test,cover
#+ 188 ms @ @ Use ./package.json
#
# +898 ms @ @ Run lint
# ...
#+   1  s @ @ Done lint. Exit code 1.
#+   0 ms @ @ Stop lint, test, cover. Exit code 1.

$ abigail lint,test,cover --force
#+ 188 ms @ @ Use ./package.json
#
# +898 ms @ @ Run lint
# ...
#+   1  s @ @ Done lint. Exit code 1.
#
# +898 ms @ @ Run test
# ...
#+   1  s @ @ Done test. Exit code 0.
#
# +898 ms @ @ Run cover
# ...
#+   1  s @ @ Done cover. Exit code 0.
#+   0 ms @ @ End lint, test, cover. Exit code 1, 0, 0.
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
