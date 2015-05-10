# Dependencies
abigail= require '../'
pkg= require '../package'
path= require 'path'

argv= (str)-> str.split ' '
spawn= require './spawn-verbose'

# Spec
describe 'abigail',->
  describe 'Usage',->
    it 'Execute before Watching',(done)->
      args= [
        'node'
        require.resolve '../'
        'hoge:compile'
        '--execute'
      ]
      options=
        cwd: __dirname

      spawn(args).on 'exit',(code,error,stdout,stderr)->
        expect(stdout).toMatch /this === coffee\(script\);/g

        done()

    it 'Not using package.json',(done)->
      args= [
        'node'
        require.resolve '../'
        '*.jade:compile'
        '--execute'
      ]
      options=
        cwd: path.resolve __dirname,'fixtures'

      spawn(args,options).on 'exit',(code,error,stdout,stderr)->
        expect(stdout).toMatch /Not found .\/package.json/g
        expect(stdout).toMatch /Broken compile/g

        done()

  describe 'class Abigail',->
    properties= Object.keys abigail.__proto__

    it 'cli is CLI entry point',->
      maids= abigail.cli ["*:echo 'beep'"],off
      expect(maids.length).toEqual 1

    it 'parse is task generator',->
      [tasks,options,scripts]= abigail.parse ["*:'echo beep'",'-e','-i'],off
      expect(tasks).toEqual [glob:'*',raw:'echo beep',script:'echo beep']
      expect(Object.keys options).toEqual ['execute','ignored']
      expect(scripts).toEqual pkg.scripts

    it 'getIgnored is return marged gitignore',->
      ignored= abigail.getIgnored(off)
      expect(ignored instanceof Array).toBeTruthy()

    it '_log is Date.now()',->
      expect(typeof abigail._log).toEqual 'number'

    it 'log is console.log wrapper',->
      expect(typeof abigail.log).toEqual 'function'

    xit 'help is Output usage',->
      abigail.help()

    it 'icon is @_@',->
      chalk= require 'chalk'
      expect(abigail.icon).toEqual chalk.magenta '@'+chalk.underline(' ')+'@'

  describe '.parse',->
    it 'single',->
      [tasks,options]= abigail.parse argv "*:test"

      expect(tasks).toEqual [
        {glob:'*',raw:'test',script:'npm run test'}
      ]

    it 'multiple',->
      [tasks,options]= abigail.parse argv "*:test *:start *:build *.coffee:compile"

      expect(tasks).toEqual [
        {glob:'*',raw:'test',script:'npm run test'}
        {glob:'*',raw:'start',script:'npm run start'}
        {glob:'*',raw:'build',script:'npm run build'}
        {glob:'*.coffee',raw:'compile',script:'npm run compile'}
      ]

    it 'raw script',->
      [tasks,options]= abigail.parse argv "*:'hoge' *:'fuga' *:'piyo' *.coffee:'compile'"

      expect(tasks).toEqual [
        {glob:'*',raw:'hoge',script:'hoge'}
        {glob:'*',raw:'fuga',script:'fuga'}
        {glob:'*',raw:'piyo',script:'piyo'}
        {glob:'*.coffee',raw:'compile',script:'compile'}
      ]