![Abigail](https://cloud.githubusercontent.com/assets/1548478/14227243/06457ec6-f934-11e5-9b30-a37a13ce1d4e.png)
---

<p align="right">
  <a href="https://npmjs.org/package/abigail">
    <img src="https://img.shields.io/npm/v/abigail.svg?style=flat-square">
  </a>
  <a href="https://travis-ci.org/abigailjs/abigail">
    <img src="http://img.shields.io/travis/abigailjs/abigail.svg?style=flat-square">
  </a>
  <a href="https://codeclimate.com/github/abigailjs/abigail/coverage">
    <img src="https://img.shields.io/codeclimate/github/abigailjs/abigail.svg?style=flat-square">
  </a>
  <a href="https://codeclimate.com/github/abigailjs/abigail">
    <img src="https://img.shields.io/codeclimate/coverage/github/abigailjs/abigail.svg?style=flat-square">
  </a>
  <a href="https://gemnasium.com/abigailjs/abigail">
    <img src="https://img.shields.io/gemnasium/abigailjs/abigail.svg?style=flat-square">
  </a>
</p>

Installation
---
```bash
npm install abigail --global
# or
yarn global add abigail
```

Usage
---

abigail is [npm scripts](https://docs.npmjs.com/misc/scripts) emulator.
You can succinctly describe the serial run-script and watch files.

```bash
abby test, lint, cover.
# +    0 ms @_@ use package.json.
# +    2 ms @_@ plugin enabled exit, log, launch, watch.
# +   23 ms @_@ task start test, lint, cover.
# +    0 ms @_@ task end test, lint, cover. exit code 0, 0, 0.
# +    0 ms @_@ cheers for good work.
```

In addition, makes it easy to change the settings using optional arguments.

```bash
abby test --no-log
# ...
> _
```

or specify package.json `abigail` field.

```json
{
  "scripts": {
    "test": "mocha"
  },
  "abigail": {
    "plugins": {
      "watch": "{*,src/**/*.jsx,test/**/*.jsx}"
    }
  }
}
```

```bash
abby test
```

Serial run-script
---
If connecting the script name with a comma, run the script in serial.

```bash
abby cover, report.
# +   23 ms @_@ task start cover, report.
# +    3 ms @_@ script start cover.
# +  6.3  s @_@ script end cover. exit code 0.
# +    3 ms @_@ script start report.
# +  6.3  s @_@ script end report. exit code 0.
# +  5.1  s @_@ task end cover, report. exit code 0, 0.
```

Parallel run-script
---
Unless connecting the script name with a comma, run the script in parallel.

```bash
abby babel jade stylus
# ...
# +  133 ms @_@ script end stylus. exit code 0.
# +   87 ms @_@ script end jade. exit code 0.
# +   93 ms @_@ script end babel. exit code 0.
# +    0 ms @_@ task end babel, jade, stylus. exit code 0, 0, 0.
```

Run binary script
---
Cause abigail is know path of the local-installed, Can run the bin of `node_modules/.bin/` instead of missing script.

```bash
abby flow
# ...
# +    8 ms @_@; Error: spawn flow ENOENT
# ...

npm install flow-bin
abby flow
# ...
# No errors!
# ...
```

See detail is to [abigail-parse-plugin](https://github.com/abigailjs/abigail-plugin-parse#abigail-parse-plugin).

Continuous script
---
Can run scirpt continuously using the builtin `--watch` plugin.

```bash
abby test --watch
# ...
# +  1.0  s @_@ task end test. exit code 0.
# +    1 ms @_@ ... watch at src/**/*.js, test/**/*.js.

abby flow --watch '{src,test}/**/*.js'
# ...
# No errors!
# +  113 ms @_@ task end flow. exit code 0.
# +    0 ms @_@ ... watch at {src,test}/**/*.js.
```

See detail is to [abigail-plugin-watch](https://github.com/abigailjs/abigail-plugin-watch#abigail-watch-plugin).

Glob run-script
---
If specify glob the script name, run the matching scripts in **serial**.

```bash
abby mytask:*
# ...
# +  133 ms @_@ script end mytask:stylus. exit code 0.
# +    0 ms @_@ script start mytask:jade. exit code 0.
# ...
# +   87 ms @_@ script end mytask:jade. exit code 0.
# +    0 ms @_@ script start mytask:babel. exit code 0.
# ...
# +   93 ms @_@ script end mytask:babel. exit code 0.
# +    0 ms @_@ task end mytask:babel, mytask:jade, mytask:stylus. exit code 0, 0, 0.
```

Bail run-script
---
If specify `--launch bail`, to strict serial run-script(not ignore the error and continues).

```bash
abby cover, report.
# +   23 ms @_@ task start cover, report.
# +    3 ms @_@ script start cover.
# ...
# +  6.3  s @_@ script end cover. exit code 1.
# +    3 ms @_@ script start report.
# ...
# +  198 ms @_@ script end report. exit code 0.
# +    2 ms @_@ task end cover, report. exit code 1, 0.

abby cover, report. --launch bail
# +   23 ms @_@ task start cover, report.
# +    3 ms @_@ script start cover.
# +  6.3  s @_@ script end cover. exit code 1.
# +  5.1  s @_@ task end cover. exit code 1.
```

Run with script
---
if specify `--`, it run the subsequent arguments as the end of the script.

```bash
abby cover:* -- --quiet
# +   23 ms @_@ task start cover:test. (with --quiet)
# ...
```

If the locally use, use the double quote(`""`).

```bash
abby cant-quiet-task "cover:* -- --quiet"
# +   23 ms @_@ task start cant-quiet-task, cover:test.
# +    3 ms @_@ script start cant-quiet-task.
# +    3 ms @_@ script start cover:test. (with  --quiet)
# ...
```

See also
---
* [abigail-plugin-env](https://github.com/abigailjs/abigail-plugin-env#usage)
* [abigail-plugin-exit](https://github.com/abigailjs/abigail-plugin-exit#usage)
* [abigail-plugin-launch](https://github.com/abigailjs/abigail-plugin-launch#usage)
* [abigail-plugin-log](https://github.com/abigailjs/abigail-plugin-log#usage)
* [abigail-plugin-parse](https://github.com/abigailjs/abigail-plugin-parse#usage)
* [abigail-plugin-watch](https://github.com/abigailjs/abigail-plugin-watch#usage)

Inspired by
---
* [npm-run-all](https://github.com/mysticatea/npm-run-all)
* [onchange](https://github.com/Qard/onchange)

Development
---
Requirement global
* NodeJS v5.7.0
* Npm v3.7.1

```bash
git clone https://github.com/abigailjs/abigail
cd abigail
npm install

npm test
```

License
---
[MIT](http://59naga.mit-license.org/)
