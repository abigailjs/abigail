abigail= require './'
path= require 'path'
childProcess= require 'child_process'

argv= (str)-> str.split ' '

describe 'abigail',->
  describe '.cli',->
    it 'boot after run',(done)->
      args= [
        'node'
        require.resolve './'
        '*:compile'
        '--execute'
      ]

      setTimeout (-> child.kill()),2000
      child= childProcess.exec args.join(' '),(error,stdout,stderr)->
        expect(stdout).toMatch /this === coffee\(script\);/g

        done()

    it 'without package.json',(done)->
      args= [
        'node'
        require.resolve './'
        '*:compile'
        '--execute'
      ]
      options=
        cwd: path.resolve process.cwd(),'../'

      setTimeout (-> child.kill()),2000
      child= childProcess.exec args.join(' '),options,(error,stdout,stderr)->
        expect(error.toString()).toMatch /Command failed/g

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