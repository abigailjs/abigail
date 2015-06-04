# TODO: More test. More More test.

# Dependencies
Abigail= (require '../src').Abigail
Task= (require '../src/task').Task

path= require 'path'

# Fixture
$abigail= (args)->
  argv= ['node',__filename]
  for arg in args.match /".*?"|[^\s]+/g
    argv.push arg.replace /^"|"$/g,''

  cli= new Abigail
  cli.test= yes
  cli.parse argv

  cli

# Specs
describe 'CLI',->
  describe 'Task',->
    describe 'Multi glob',->
      it '$ abigail test src/**,test/**',->
        cli= $abigail 'test src/**,test/**'

        arg= cli.args[0]
        expect(arg.scripts[0]).toEqual 'npm run test'
        expect(arg.scripts[0].lazy).toBe false
        expect(arg.globs[0]).toEqual 'src/**'
        expect(arg.globs[1]).toBe 'test/**'

    describe 'Multi script',->
      it '$ abigail cover,lint,beep src/**,test/**',->
        cli= $abigail 'test,compile,_beep src/**,test/**'

        arg= cli.args[0]
        expect(arg.scripts[0]).toEqual 'npm run test'
        expect(arg.scripts[0].lazy).toBe false
        expect(arg.scripts[1]).toEqual 'npm run compile'
        expect(arg.scripts[1].lazy).toBe false
        expect(arg.scripts[2]).toEqual 'beep'
        expect(arg.scripts[2].lazy).toBe true
        expect(arg.globs[0]).toEqual 'src/**'
        expect(arg.globs[1]).toBe 'test/**'

    describe 'Multi task',->
      it '$ abigail _test src/**,test/** _compile,foo bar,baz',->
        cli= $abigail '_test src/**,test/** _compile,foo bar,baz'

        arg= cli.args[0]
        expect(arg.scripts[0]).toEqual 'npm run test'
        expect(arg.scripts[0].lazy).toBe true
        expect(arg.globs[0]).toEqual 'src/**'
        expect(arg.globs[1]).toBe 'test/**'

        arg= cli.args[1]
        expect(arg.scripts[0]).toEqual 'npm run compile'
        expect(arg.scripts[0].lazy).toBe true
        expect(arg.scripts[1]).toEqual 'foo'
        expect(arg.scripts[1].lazy).toBe false
        expect(arg.globs[0]).toEqual 'bar'
        expect(arg.globs[1]).toBe 'baz'

  describe 'Lazy script',->
    it '$ abigail _test test/**',->
      cli= $abigail '_test src/**,test/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'npm run test'
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'

  describe 'Exclude from watch',->
    it '$ abigail test **,_node_modules',->
      cli= $abigail 'test **,_node_modules'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'npm run test'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual '**'
      expect(arg.globs[1]).toBe '!node_modules'

  describe 'Raw script',->
    it '$ abigail "raw script" src/**',->
      cli= $abigail '"raw script" src/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'raw script'
      expect(arg.scripts[0].lazy).toBe false
      expect(arg.globs[0]).toEqual 'src/**'

    it '$ abigail "_raw script" src/**',->
      cli= $abigail '"_raw script" src/**'

      arg= cli.args[0]
      expect(arg.scripts[0]).toEqual 'raw script'
      expect(arg.scripts[0].lazy).toBe true
      expect(arg.globs[0]).toEqual 'src/**'
