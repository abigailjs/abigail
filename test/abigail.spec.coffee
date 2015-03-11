abigail= require '../'
path= require 'path'
childProcess= require 'child_process'

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

describe 'abigail',->
  it 'Execute before Watching',(done)->
    args= [
      'node'
      require.resolve '../'
      'hoge:compile'
      '--execute'
    ]

    verboseChildProcess(args).on 'exit',(code,error,stdout,stderr)->
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
      cwd: path.resolve process.cwd(),'../'

    verboseChildProcess(args,options).on 'exit',(code,error,stdout,stderr)->
      expect(stdout).toMatch /Not found .\/package.json/g
      expect(stdout).toMatch /Broken compile/g

      done()

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