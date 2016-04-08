<a name="1.4.1"></a>
## [1.4.1](https://github.com/abigailjs/abigail/compare/v1.4.0...v1.4.1) (2016-04-08)


### Features

* **dash:** run argument after dash(`--`) as a plug-in file ([489d42a](https://github.com/abigailjs/abigail/commit/489d42a)), closes [#14](https://github.com/abigailjs/abigail/issues/14)



<a name="1.4.0"></a>
# [1.4.0](https://github.com/abigailjs/abigail/compare/v1.3.3...v1.4.0) (2016-04-08)


### Bug Fixes

* **array-from:** chopsticks@0.0.1 ([e1d1fda](https://github.com/abigailjs/abigail/commit/e1d1fda))
* **Object.assign:** `TypeError: undefined is not a function` at v0 ([31714a9](https://github.com/abigailjs/abigail/commit/31714a9))
* **Object.assign:** fix #11 ([be2d19d](https://github.com/abigailjs/abigail/commit/be2d19d)), closes [#11](https://github.com/abigailjs/abigail/issues/11)
* **v0:** always transform Object.assign to polyfill ([3f02590](https://github.com/abigailjs/abigail/commit/3f02590))

### Code Refactoring

* **parse:** use chopstick@0.3 ([61ccf86](https://github.com/abigailjs/abigail/commit/61ccf86))


### BREAKING CHANGES

* parse: serial execution will support the right-comma only



<a name="1.3.3"></a>
## [1.3.3](https://github.com/abigailjs/abigail/compare/v1.2.0...v1.3.3) (2016-04-02)


### Bug Fixes

* **loadPlugins:** package.json abigail/plugins field ([d341b88](https://github.com/abigailjs/abigail/commit/d341b88))
* replace ES6 methods (String.raw, Object.assign, arrow-functions) ([a4e97cc](https://github.com/abigailjs/abigail/commit/a4e97cc)), closes [#11](https://github.com/abigailjs/abigail/issues/11)

### Features

* **loadPlugins:** change the plugin option only to object ([e5a749d](https://github.com/abigailjs/abigail/commit/e5a749d))
* add `resolvePluginOptions` ([9f29021](https://github.com/abigailjs/abigail/commit/9f29021))
* **parse:** add `--parse serial` option ([c209319](https://github.com/abigailjs/abigail/commit/c209319))
* **watch:** add `lazy` option ([c3fcebc](https://github.com/abigailjs/abigail/commit/c3fcebc))


### BREAKING CHANGES

* loadPlugins: remove/add all specs of loadPlugins



<a name="1.2.0"></a>
# [1.2.0](https://github.com/abigailjs/abigail/compare/v1.1.4...v1.2.0) (2016-04-02)


### Bug Fixes

* fix #8, #9 ([6eff1af](https://github.com/abigailjs/abigail/commit/6eff1af)), closes [#8](https://github.com/abigailjs/abigail/issues/8) [#9](https://github.com/abigailjs/abigail/issues/9)
* **watch:** fix #10 ([487622e](https://github.com/abigailjs/abigail/commit/487622e)), closes [#10](https://github.com/abigailjs/abigail/issues/10)

### Features

* **rc:** add `value.default` plugin option ([00496a5](https://github.com/abigailjs/abigail/commit/00496a5))



<a name="1.1.4"></a>
## [1.1.4](https://github.com/abigailjs/abigail/compare/v1.1.3...v1.1.4) (2016-03-29)




<a name="1.1.3"></a>
## [1.1.3](https://github.com/abigailjs/abigail/compare/v1.1.2...v1.1.3) (2016-03-29)


### Bug Fixes

* uptodate abigail-plugin-parse@0.0.1 (fix #7) ([44b4518](https://github.com/abigailjs/abigail/commit/44b4518)), closes [#7](https://github.com/abigailjs/abigail/issues/7)



<a name="1.1.2"></a>
## [1.1.2](https://github.com/abigailjs/abigail/compare/v1.0.0...v1.1.2) (2016-03-28)


### Bug Fixes

* hide the pass/fail message ([fb55202](https://github.com/abigailjs/abigail/commit/fb55202))
* **abby:** fix #6 ([5a4e33d](https://github.com/abigailjs/abigail/commit/5a4e33d)), closes [#6](https://github.com/abigailjs/abigail/issues/6)
* **abigail-plugin-launch:** uptodate 0.0.3 ([833bd3e](https://github.com/abigailjs/abigail/commit/833bd3e))

### Code Refactoring

* move parse functions to abigail-plugin-parse ([86c6676](https://github.com/abigailjs/abigail/commit/86c6676))


### BREAKING CHANGES

* rename all properties to `this.props`



<a name="1.0.0"></a>
# [1.0.0](https://github.com/abigailjs/abigail/compare/1c3c397...v1.0.0) (2016-03-25)


### Bug Fixes

* **utils.lookupJson:** doesn't handle the broken json ([1c3c397](https://github.com/abigailjs/abigail/commit/1c3c397))

### Features

* add version output with exit code 0(fix #5) ([6e9b2dd](https://github.com/abigailjs/abigail/commit/6e9b2dd)), closes [#5](https://github.com/abigailjs/abigail/issues/5)



