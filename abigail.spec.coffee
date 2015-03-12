abigail= require './'
path= require 'path'
childProcess= require 'child_process'

describe 'abigail',->
  describe 'Usage',->
    it 'Execute before Watching',(done)->
      args= [
        'node'
        require.resolve './'
        'hoge:compile'
        '--execute'
      ]
      options=
        cwd: __dirname

      verboseChildProcess(args).on 'exit',(code,error,stdout,stderr)->
        expect(stdout).toMatch /this === coffee\(script\);/g

        done()

    it 'Not using package.json',(done)->
      args= [
        'node'
        require.resolve './'
        '*.jade:compile'
        '--execute'
      ]
      options=
        cwd: path.resolve __dirname,'fixtures'

      verboseChildProcess(args,options).on 'exit',(code,error,stdout,stderr)->
        expect(stdout).toMatch /Not found .\/package.json/g
        expect(stdout).toMatch /Broken compile/g

        done()

  describe 'class Abigail',->
    abigail= require './'
    properties= Object.keys abigail.__proto__

    it 'cli is CLI entry point',->
      maids= abigail.cli ["*:echo 'beep'"]
      expect(maids.length).toEqual 1

    it 'parse is task generator',->
      [tasks,options,scripts]= abigail.parse ["*:'echo beep'",'-e','-i']
      expect(tasks).toEqual [glob:'*',raw:'echo beep',script:'echo beep']
      expect(Object.keys options).toEqual ['execute','ignored']
      expect(scripts).toEqual require('./package').scripts

    it 'getIgnored is return marged gitignore',->
      ignored= abigail.getIgnored()
      expect(ignored instanceof Array).toBeTruthy()

    it '_log is Date.now()',->
      expect(typeof abigail._log).toEqual 'number'

    it 'log is console.log wrapper',->
      expect(typeof abigail.log()).toEqual 'number'

    xit 'help is Output usage',->
      abigail.help()

    it 'icon is @_@',->
      chalk= require 'chalk'
      expect(abigail.icon).toEqual chalk.magenta '@'+chalk.underline(' ')+'@'

    it "... #{properties.length} properties is defined",->
      expect(properties).toEqual [
        'cli'
        'parse'
        'getIgnored'
        '_log'
        'log'
        'help'
        'icon'
      ]

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

argv= (str)-> str.split ' '
verboseChildProcess= (args,options={},timeout=1000)->
  manager= new (require('events').EventEmitter)

  setTimeout ->
    child.kill()
  ,timeout
  [bin,args...]= args
  options.cwd?= process.cwd()

  console.log ''

  error= stdout= stderr= ''
  child= require('child_process').spawn bin,args,options
  child.on 'error',(error)->
    error+= error.stack.toString()
    console.error 'Error:',error.stack.toString()

  child.stdout.on 'data',(buffer)->
    stdout+= buffer.toString()
    process.stdout.write buffer

  child.stderr.on 'data',(buffer)->
    stderr+= buffer.toString()
    process.stderr.write buffer

  child.on 'exit',(code)->
    manager.emit 'exit',code,error,stdout,stderr

  manager